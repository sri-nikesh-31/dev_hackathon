import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> getIncidents() {
    return _db
        .collection('incidents')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  static Future<void> upvote(String id, int current) async {
    await _db.collection('incidents').doc(id).update({
      'upvotes': current + 1,
    });
  }

  static Future<void> updateStatus(String id, String status) async {
    await _db.collection('incidents').doc(id).update({
      'status': status,
    });
  }
}
