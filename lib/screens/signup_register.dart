import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // เรียกใช้ Service
import 'home_screen.dart'; // เรียกใช้หน้า Home

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // 1. ตัวแปรรับค่า
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  bool _isLoading = false;

  bool obscure1 = true;
  bool obscure2 = true;

  final Color primary = const Color(0xFFE88974); // ปรับสีส้มพีชให้ตรงกับหน้า Profile

  // --- ฟังก์ชันสมัครสมาชิก ---
  void _handleSignUp() async {
    String fullname = _fullnameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    // Validation
    if (fullname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
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

    setState(() => _isLoading = true);

    // --- จุดที่แก้ไข: เรียงลำดับตัวแปรใหม่ให้ตรงกับ AuthService (fullname, email, password) ---
    var user = await _authService.register(fullname, email, password);

    setState(() => _isLoading = false);

    if (user != null) {
      if (mounted) {
        _showSnack("สมัครสมาชิกสำเร็จ!");
        // สมัครสำเร็จ -> ไปหน้า Home
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
        );
      }
    } else {
      // หาก user เป็น null แสดงว่ามี Error ใน AuthService (เช่น Email ซ้ำ หรือ Firestore บันทึกไม่ได้)
      _showSnack("สมัครไม่สำเร็จ: อีเมลนี้อาจถูกใช้ไปแล้ว หรือเกิดข้อผิดพลาดที่ระบบ");
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 50),

                // --- LOGO (ดีไซน์เดียวกับหน้า Profile) ---
                Center(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _letter("T O"),
                              _letter("D O"),
                              _letter("L I S T"),
                            ],
                          ),
                          const SizedBox(width: 5),
                          Icon(Icons.check_box_outlined, color: primary, size: 30),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // --- Input Fields ---
                _input("Full Name", controller: _fullnameController, icon: Icons.person_outline),
                const SizedBox(height: 18),
                _input("Email Address", controller: _emailController, icon: Icons.email_outlined),
                const SizedBox(height: 18),
                _input("Password",
                    controller: _passwordController,
                    isPass: true,
                    obscure: obscure1,
                    icon: Icons.lock_outline,
                    toggle: () => setState(() => obscure1 = !obscure1)),
                const SizedBox(height: 18),
                _input("Confirm Password",
                    controller: _confirmPasswordController,
                    isPass: true,
                    obscure: obscure2,
                    icon: Icons.lock_reset_outlined,
                    toggle: () => setState(() => obscure2 = !obscure2)),

                const SizedBox(height: 35),

                // --- SIGN UP BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                    ),
                    onPressed: _isLoading ? null : _handleSignUp,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "CREATE ACCOUNT",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // --- Link to Login ---
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text.rich(
                    TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.grey),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: TextStyle(color: primary, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
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
      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primary, height: 1.1),
    );
  }

  Widget _input(String hint,
      {required IconData icon,
        bool isPass = false,
        bool obscure = false,
        VoidCallback? toggle,
        TextEditingController? controller}) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFFF8F8F8),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        suffixIcon: isPass
            ? IconButton(
          icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }
}