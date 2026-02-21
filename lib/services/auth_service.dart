import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // สมัครสมาชิกพร้อมบันทึกชื่อลง Firestore
  Future<User?> register(String fullname, String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      if (user != null) {
        await user.updateDisplayName(fullname);
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullname': fullname,
          'email': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return user;
    } catch (e) {
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return result.user;
    } catch (e) {
      return null;
    }
  }

  Future<void> logout() async => await _auth.signOut();
}