import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignUpPage(),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  bool obscure1 = true;
  bool obscure2 = true;

  final Color primary = const Color(0xFFE9967A);

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

                const SizedBox(height: 80),

                /// LOGO
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
                              _letter("T"),
                              const SizedBox(width: 30),
                              _letter("O"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter("D"),
                              const SizedBox(width: 30),
                              _letter("O"),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _letter("L"),
                              const SizedBox(width: 28),
                              _letter("I"),
                              const SizedBox(width: 28),
                              _letter("S"),
                              const SizedBox(width: 28),
                              _letter("T"),
                            ],
                          ),
                        ],
                      ),
                      Positioned(
                        right: -4,
                        top: 8,
                        child: Icon(
                          Icons.check_box_outlined,
                          color: primary,
                          size: 24,
                        ),
                      )
                    ],
                  ),
                ),

                const SizedBox(height: 60),

                _input("Email"),
                const SizedBox(height: 18),
                _input("Full Name"),
                const SizedBox(height: 18),
                _input("Password",
                    isPass: true,
                    obscure: obscure1,
                    toggle: () {
                      setState(() => obscure1 = !obscure1);
                    }),
                const SizedBox(height: 18),
                _input("Confirm Password",
                    isPass: true,
                    obscure: obscure2,
                    toggle: () {
                      setState(() => obscure2 = !obscure2);
                    }),

                const SizedBox(height: 35),

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
                    onPressed: () {},
                    child: const Text(
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

                Text.rich(
                  TextSpan(
                    text: "Have an account? ",
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 12),
                    children: [
                      TextSpan(
                        text: "Log in",
                        style: TextStyle(color: primary),
                      )
                    ],
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
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
    );
  }

  Widget _input(String hint,
      {bool isPass = false,
        bool obscure = false,
        VoidCallback? toggle}) {
    return TextField(
      obscureText: obscure,
      decoration: InputDecoration(
        hintText: hint,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: primary),
        ),
        suffixIcon: isPass
            ? IconButton(
          icon: Icon(
            obscure
                ? Icons.visibility_off
                : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: toggle,
        )
            : null,
      ),
    );
  }
}
