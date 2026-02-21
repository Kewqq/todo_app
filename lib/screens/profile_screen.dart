import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ใช้สีตาม Theme ของหน้า Login เพื่อความสวยงาม
  static const Color primaryColor = Color(0xFFE88974);

  String _fullName = "Loading...";
  String _email = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // --- 1. ดึงข้อมูลผู้ใช้จาก Firebase ---
  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _email = currentUser.email ?? "No Email";
      });

      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            _fullName = userDoc['fullname'] ?? "No Name";
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
      }
    }
  }

  // --- 2. ฟังก์ชันแสดง Pop-up เปลี่ยนชื่อ ---
  void _showEditNameDialog() {
    TextEditingController nameController = TextEditingController(text: _fullName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Full Name"),
          content: TextField(
            controller: nameController,
            decoration: const InputDecoration(
              hintText: "Enter your new name",
              focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: primaryColor)),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel", style: TextStyle(color: Colors.grey))
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    try {
                      Navigator.pop(context);
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .set({'fullname': newName}, SetOptions(merge: true));

                      await currentUser.updateDisplayName(newName);

                      if (mounted) {
                        setState(() => _fullName = newName);
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("อัปเดตชื่อสำเร็จ!"))
                        );
                      }
                    } catch (e) {
                      debugPrint("Save Error: $e");
                    }
                  }
                }
              },
              child: const Text("Save", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // แก้ไขปัญหาจอดำโดยการ Push กลับไปหน้า Home โดยตรง
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
                  (route) => false,
            );
          },
        ),
        title: const Text("PROFILE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // --- LOGO SECTION (เปลี่ยนจากรูปคนเป็น Logo แบบหน้า Login) ---
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('T O', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, height: 1.1)),
                            Text('D O', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, height: 1.1)),
                            Text('L I S T', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryColor, height: 1.1)),
                          ],
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.check_box_outlined, size: 28, color: primaryColor),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 50),

              // --- INFO ---
              _buildInfoRow("Full Name", _fullName, onEdit: _showEditNameDialog),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),

              _buildInfoRow("Email", _email),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8.0), child: Divider()),

              const Spacer(),

              // --- LOGOUT BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                              (route) => false
                      );
                    }
                  },
                  child: const Text("LOG OUT", style: TextStyle(fontSize: 16, color: Colors.white, letterSpacing: 1, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, {VoidCallback? onEdit}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(fontSize: 18, color: Colors.black87, fontWeight: FontWeight.w500)),
          ],
        ),
        if (onEdit != null)
          IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_outlined, color: primaryColor)),
      ],
    );
  }
}