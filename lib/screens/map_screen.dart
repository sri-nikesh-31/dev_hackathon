import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Incident Map")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('incidents')
            .snapshots(),
        builder: (_, snapshot) {
          if (!snapshot.hasData) return Container();

          final markers = snapshot.data!.docs.map((doc) {
            return Marker(
              markerId: MarkerId(doc.id),
              position:
              LatLng(doc['latitude'], doc['longitude']),
              infoWindow: InfoWindow(
                title: doc['type'],
                snippet: doc['status'],
              ),
            );
          }).toSet();

          return GoogleMap(
            initialCameraPosition:
            const CameraPosition(target: LatLng(22.5, 75.9), zoom: 12),
            markers: markers,
          );
        },
      ),
    );
  }
}
