import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 1. สมัครสมาชิก (Register)
  Future<User?> register(String email, String password) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
      );
      return result.user;
    } catch (e) {
      print("Register Error: $e");
      return null;
    }
  }

  // 2. ล็อกอิน (Login)
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password
      );
      return result.user;
    } catch (e) {
      print("Login Error: $e");
      return null;
    }
  }

  // 3. ล็อกเอาท์ (Logout)
  Future<void> logout() async {
    await _auth.signOut();
  }

  // 4. เช็คว่าใครล็อกอินอยู่ (Get Current User)
  User? getCurrentUser() {
    return _auth.currentUser;
  }
}