import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // เรียกใช้ Service
import 'home_screen.dart'; // เรียกใช้หน้า Home

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 1. สร้างตัวแปรรับค่า
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController(); // (เผื่อใช้ในอนาคต)
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool obscure1 = true;
  bool obscure2 = true;

  final Color primary = const Color(0xFFE9967A); // สีส้มพีชตาม Theme

  // --- ฟังก์ชันสมัครสมาชิก ---
  void _handleSignUp() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validation ตรวจสอบความถูกต้อง
    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showSnack("กรุณากรอกข้อมูลให้ครบถ้วน");
      return;
    }

    if (password != confirmPassword) {
      _showSnack("รหัสผ่านไม่ตรงกัน");
      return;
    }

    if (password.length < 6) {
      _showSnack("รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร");
      return;
    }

    setState(() => _isLoading = true); // เริ่มโหลด

    // ส่งไปสร้าง User ที่ Firebase
    var user = await _authService.register(email, password);

    setState(() => _isLoading = false); // หยุดโหลด

    if (user != null) {
      // สมัครสำเร็จ -> ไปหน้า Home (แบบล้างประวัติหน้าเก่าทิ้ง)
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } else {
      _showSnack("สมัครไม่สำเร็จ (อีเมลนี้อาจถูกใช้ไปแล้ว)");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF3F3F3),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // --- LOGO (ใช้โค้ดเดิมของคุณ) ---
                Center(
                  child: Stack(
                    alignment: Alignment.topRight,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter("T"), const SizedBox(width: 30), _letter("O"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter("D"), const SizedBox(width: 30), _letter("O"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter("L"), const SizedBox(width: 28),
                              _letter("I"), const SizedBox(width: 28),
                              _letter("S"), const SizedBox(width: 28),
                              _letter("T"),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: -4, top: 8,
                        child: Icon(Icons.check_box_outlined, color: primary, size: 24),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Input Fields ---
                _input("Email", controller: _emailController),
                const SizedBox(height: 18),
                _input("Full Name", controller: _fullNameController),
                const SizedBox(height: 18),
                _input("Password",
                    controller: _passwordController,
                    isPass: true,
                    obscure: obscure1,
                    toggle: () => setState(() => obscure1 = !obscure1)),
                const SizedBox(height: 18),
                _input("Confirm Password",
                    controller: _confirmPasswordController,
                    isPass: true,
                    obscure: obscure2,
                    toggle: () => setState(() => obscure2 = !obscure2)),

                const SizedBox(height: 35),

                // --- SIGN UP BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSignUp, // เชื่อมฟังก์ชันตรงนี้
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.white,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // --- Link to Login ---
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context); // กดแล้วย้อนกลับไปหน้า Login
                  },
                  child: Text.rich(
                    TextSpan(
                      text: "Have an account? ",
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      children: [
                        TextSpan(
                          text: "Log in",
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _letter(String text) {
    return Text(
      text,
      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w500, color: primary),
    );
  }

  // แก้ไข Widget _input ให้รับ controller
  Widget _input(String hint,
      {bool isPass = false,
        bool obscure = false,
        VoidCallback? toggle,
        TextEditingController? controller}) { // เพิ่ม Parameter controller
    return TextField(
      controller: controller, // ผูกตัวแปรตรงนี้
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary),
        ),
        suffixIcon: isPass
            ? IconButton(
          icon: Icon(
            obscure ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }
}