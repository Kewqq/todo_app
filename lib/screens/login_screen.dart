import 'package:flutter/material.dart';
import 'package:todo_app/screens/signup_register.dart';
import '../services/auth_service.dart'; // เรียกใช้ Service ที่เราสร้างไว้
import 'home_screen.dart'; // เรียกใช้หน้า Home

// Class สี (ถ้าคุณแยกไฟล์แล้ว ให้ลบส่วนนี้ออกแล้ว import 'colors.dart' แทนครับ)
class AppColors {
  static const Color primaryColor = Color(0xFFF49E89);
  static const Color secondaryColor = Color(0xFF9E9E9E);
  static const Color backgroundColor = Colors.white;
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. ตัวแปรสำหรับรับค่าจากช่องกรอก
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. เรียกใช้ตัวจัดการ Auth
  final AuthService _authService = AuthService();

  // สถานะโหลด (เอาไว้หมุนติ้วๆ เวลาเน็ตช้า)
  bool _isLoading = false;

  // --- ฟังก์ชัน Login ---
  void _handleLogin() async {
    // เก็บค่าใส่ตัวแปร
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("กรุณากรอกข้อมูลให้ครบ");
      return;
    }

    setState(() => _isLoading = true); // เริ่มโหลด

    // ส่งไปตรวจสอบกับ Firebase
    var user = await _authService.login(email, password);

    setState(() => _isLoading = false); // หยุดโหลด

    if (user != null) {
      // ถ้าผ่าน -> ไปหน้า Home
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      _showSnack("Login ไม่สำเร็จ! อีเมลหรือรหัสผ่านผิด");
    }
  }

  // --- ฟังก์ชันสมัครสมาชิก (Sign Up) ---
  void _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnack("กรุณากรอกอีเมลและรหัสผ่านเพื่อสมัคร");
      return;
    }

    setState(() => _isLoading = true);

    // สร้าง User ใหม่ใน Firebase
    var user = await _authService.register(email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      _showSnack("สมัครสมาชิกสำเร็จ! กำลังเข้าสู่ระบบ...");
      // ไปหน้า Home เหมือนกัน
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      _showSnack("สมัครไม่สำเร็จ (อีเมลนี้อาจมีคนใช้แล้ว)");
    }
  }

  // ฟังก์ชันแสดงข้อความแจ้งเตือนด้านล่าง
  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.primaryColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView( // ใส่ ScrollView เผื่อคีย์บอร์ดบัง
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Section (ตามดีไซน์เดิม)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('T O', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryColor, letterSpacing: 4)),
                        Text('D O', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryColor, letterSpacing: 4)),
                        Text('L I S T', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: AppColors.primaryColor, letterSpacing: 4)),
                      ],
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.check_box_outlined, size: 50, color: AppColors.primaryColor),
                  ],
                ),
                const SizedBox(height: 80),

                // Email Input
                TextField(
                  controller: _emailController, // เชื่อมตัวแปร
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: AppColors.secondaryColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.secondaryColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.secondaryColor)),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController, // เชื่อมตัวแปร
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: AppColors.secondaryColor),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.secondaryColor)),
                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0), borderSide: const BorderSide(color: AppColors.secondaryColor)),
                    suffixIcon: const Icon(Icons.visibility_off_outlined, color: AppColors.secondaryColor),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin, // ถ้าโหลดอยู่กดไม่ได้
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white) // หมุนติ้วๆ
                        : const Text('SIGN IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),

                // Sign Up Link (กดแล้วสมัครเลย)
                // ค้นหาโค้ดส่วนด้านล่างสุดของ LoginScreen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? "),
                    GestureDetector(
                      onTap: () {
                        // --- เปลี่ยนตรงนี้ ---
                        // จากเดิมที่เป็น _handleSignUp
                        // ให้เปลี่ยนเป็น Navigator.push ไปหน้า SignUpPage แทน
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text(
                        'Sign up',
                        style: TextStyle(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}