import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:dev_hackathon/theme_provider.dart';
import 'map_picker_screen.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String type = "Accident";
  final desc = TextEditingController();
  File? image;

  bool loading = false;

  // 🔥 USE SIMPLE LAT/LNG (NOT Position)
  double? latitude;
  double? longitude;

  void showMsg(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }

  // ================= LOCATION (GPS) =================
  Future<void> fetchLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showMsg("Enable location services");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        showMsg("Location permission permanently denied");
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });

      showMsg("Location captured");
    } catch (e) {
      showMsg("Location error: $e");
    }
  }

  // ================= SUBMIT =================
  Future<void> submit() async {
    if (desc.text.trim().isEmpty) {
      showMsg("Please enter description");
      return;
    }

    if (latitude == null || longitude == null) {
      showMsg("Please select a location first");
      return;
    }

    setState(() => loading = true);

    final supabase = Supabase.instance.client;
    String? imageUrl;

    try {
      // ---------- IMAGE UPLOAD ----------
      if (image != null) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}.jpg';

        await supabase.storage
            .from('incident-images')
            .upload(fileName, image!);

        imageUrl = supabase.storage
            .from('incident-images')
            .getPublicUrl(fileName);
      }

      // ---------- DATABASE INSERT ----------
      await supabase.from('incidents').insert({
        'type': type,
        'description': desc.text.trim(),
        'latitude': latitude,
        'longitude': longitude,
        'image_url': imageUrl,
        'upvotes': 0,
        'verified': false,
        'status': 'reported',
      });

      showMsg("Incident reported successfully");
      Navigator.pop(context);
    } catch (e) {
      showMsg("Submit failed: $e");
    } finally {
      setState(() => loading = false);
    }
  }

  // ================= UI =================
  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text("🚨 Report Incident"),
        actions: [
          // 🌗 THEME TOGGLE
          IconButton(
            icon: Icon(
              themeProvider.isDark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: themeProvider.toggleTheme,
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // INCIDENT TYPE
            DropdownButtonFormField<String>(
              value: type,
              decoration: const InputDecoration(
                labelText: "Incident Type",
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: "Accident", child: Text("Accident")),
                DropdownMenuItem(value: "Medical", child: Text("Medical")),
                DropdownMenuItem(value: "Fire", child: Text("Fire")),
              ],
              onChanged: (v) => setState(() => type = v!),
            ),

            const SizedBox(height: 16),

            // DESCRIPTION
            TextField(
              controller: desc,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Description",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // LOCATION CARD
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.my_location),
                    title: const Text("Use my location"),
                    onTap: fetchLocation,
                  ),
                  ListTile(
                    leading: const Icon(Icons.map),
                    title: const Text("Pick on map"),
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MapPickerScreen(),
                        ),
                      );
                      if (result != null) {
                        setState(() {
                          latitude = result.latitude;
                          longitude = result.longitude;
                        });
                        showMsg("Location selected from map");
                      }
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.shuffle),
                    title: const Text("Random nearby location"),
                    onTap: () {
                      setState(() {
                        latitude =
                            22.52 + (0.01 * (DateTime.now().millisecond % 5));
                        longitude =
                            75.92 + (0.01 * (DateTime.now().second % 5));
                      });
                      showMsg("Random location selected");
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // LOCATION DISPLAY
            Text(
              (latitude == null || longitude == null)
                  ? "📍 Location not selected"
                  : "📍 Lat: ${latitude!.toStringAsFixed(4)}, "
                  "Lng: ${longitude!.toStringAsFixed(4)}",
              style: TextStyle(color: Colors.white70),
            ),

            const SizedBox(height: 16),

            // IMAGE PREVIEW
            if (image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  image!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

            const SizedBox(height: 12),

            // IMAGE PICKER
            OutlinedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text("Add Image"),
              onPressed: () async {
                final picked = await ImagePicker()
                    .pickImage(source: ImageSource.camera);
                if (picked != null) {
                  setState(() => image = File(picked.path));
                }
              },
            ),

            const SizedBox(height: 24),

            // SUBMIT BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.redAccent,
              ),
              onPressed: loading ? null : submit,
              child: loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                "Submit Incident",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
