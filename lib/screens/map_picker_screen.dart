import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng selected = const LatLng(22.52, 75.92); // Indore default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pick Location")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selected,
          initialZoom: 13,
          onTap: (tapPosition, point) {
            setState(() => selected = point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate:
            "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.dev_hackathon',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selected,
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.location_pin,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.check),
        label: const Text("Confirm"),
        onPressed: () {
          Navigator.pop(context, selected);
        },
      ),
    );
  }
}
