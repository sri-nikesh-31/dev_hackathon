import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class IncidentDetailScreen extends StatelessWidget {
  final Map<String, dynamic> incident;

  const IncidentDetailScreen({
    super.key,
    required this.incident,
  });

  // ---------------- SAFE HELPERS ----------------

  String safeString(dynamic v, [String fallback = ""]) =>
      v == null ? fallback : v.toString();

  int safeInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return 0;
  }

  bool safeBool(dynamic v) => v == true;

  double safeDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }

  // ---------------- SEVERITY (CONSISTENT) ----------------

  Color severityColor(bool verified, int upvotes) {
    if (verified) return Colors.redAccent;
    if (upvotes >= 1) return Colors.orangeAccent;
    return Colors.grey;
  }

  String severityLabel(bool verified, int upvotes) {
    if (verified) return "Verified";
    if (upvotes >= 1) return "Unverified";
    return "New";
  }

  String incidentEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'fire':
        return "🔥";
      case 'medical':
        return "🩺";
      case 'accident':
        return "🚑";
      default:
        return "🚨";
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final type = safeString(incident['type'], 'Unknown');
    final desc = safeString(incident['description']);
    final verified = safeBool(incident['verified']);
    final upvotes = safeInt(incident['upvotes']);
    final lat = safeDouble(incident['latitude']);
    final lng = safeDouble(incident['longitude']);
    final imageUrl = incident['image_url'];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Incident Details"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            if (imageUrl != null)
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImageView(imageUrl: imageUrl),
                    ),
                  );
                },
                child: Hero(
                  tag: imageUrl,
                  child: Image.network(
                    imageUrl,
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(
                      height: 260,
                      child: Icon(Icons.broken_image),
                    ),
                  ),
                ),
              ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      Text(
                        incidentEmoji(type),
                        style: const TextStyle(fontSize: 32),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          type,
                          style: theme.textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Chip(
                        label: Text(severityLabel(verified, upvotes)),
                        backgroundColor:
                        severityColor(verified, upvotes).withOpacity(0.15),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // DESCRIPTION
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Text(desc),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LOCATION
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("📍 Location",
                              style: theme.textTheme.titleMedium),
                          const SizedBox(height: 6),
                          Text("Latitude: $lat\nLongitude: $lng"),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.map),
                            label: const Text("Open in Google Maps"),
                            onPressed: () {
                              final url = Uri.parse(
                                "https://www.google.com/maps/search/?api=1&query=$lat,$lng",
                              );
                              launchUrl(url,
                                  mode: LaunchMode.externalApplication);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CONFIRMATIONS
                  Row(
                    children: [
                      Icon(
                        verified
                            ? Icons.verified
                            : Icons.warning_amber_rounded,
                        color: severityColor(verified, upvotes),
                      ),
                      const SizedBox(width: 8),
                      Text("$upvotes confirmations"),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- FULL IMAGE ----------------

class FullImageView extends StatelessWidget {
  final String imageUrl;

  const FullImageView({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 4,
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}