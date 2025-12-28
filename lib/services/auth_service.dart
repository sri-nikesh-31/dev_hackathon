import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static Future<void> initAuth() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  static String get uid =>
      FirebaseAuth.instance.currentUser!.uid;
}
