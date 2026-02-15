import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // --- แก้ไขตรงนี้ ---
  try {
    await Firebase.initializeApp();
    print("Firebase เชื่อมต่อสำเร็จ!");
  } catch (e) {
    print("Firebase Error: $e");
    // ถึง Error ก็ปล่อยผ่านไปก่อน เพื่อให้หน้าจอขึ้น
  }

  // ย้าย runApp มาไว้นอกสุด เพื่อให้ทำงานเสมอ
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter To-Do',
      theme: ThemeData(
        primarySwatch: Colors.red,
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}