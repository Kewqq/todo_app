import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color primaryColor = Color(0xFFE88974);

  // ตัวแปรสำหรับเก็บข้อมูลที่จะเอามาโชว์
  String _fullName = "Loading...";
  String _email = "Loading...";

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // ดึงข้อมูลทันทีที่เปิดหน้านี้
  }

  // --- 1. ฟังก์ชันดึงข้อมูลผู้ใช้จาก Firebase ---
  Future<void> _fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _email = currentUser.email ?? "No Email";
      });

      try {
        // ดึงชื่อจาก Collection 'users'
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
        print("Error fetching data: $e");
      }
    }
  }

  // --- 2. ฟังก์ชันแสดง Pop-up เปลี่ยนชื่อ (อัปเดตแก้บั๊กแล้ว) ---
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
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  User? currentUser = FirebaseAuth.instance.currentUser;
                  if (currentUser != null) {
                    try {
                      // 1. ปิดหน้าต่าง Pop-up ก่อน
                      Navigator.pop(context);

                      // 2. บันทึกข้อมูลลง Firestore (ใช้ SetOptions เพื่อป้องกัน Error กรณีไม่มีข้อมูลเดิม)
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUser.uid)
                          .set({'fullname': newName}, SetOptions(merge: true));

                      // 3. อัปเดตชื่อในระบบ Auth ด้วย
                      await currentUser.updateDisplayName(newName);

                      // 4. อัปเดต UI
                      if (mounted) {
                        setState(() {
                          _fullName = newName;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("อัปเดตชื่อสำเร็จ!")),
                        );
                      }
                    } catch (e) {
                      print("Save Error: $e");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("เกิดข้อผิดพลาด: $e", style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
                        );
                      }
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

  // --- 3. ฟังก์ชันจำลองการกดอัปโหลดรูป ---
  void _pickImage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("รอติดตั้งระบบอัปโหลดรูปในสเตปต่อไปนะครับ!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        // ปุ่มลูกศรฝั่งซ้าย
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // กดย้อนกลับไปหน้า HomeScreen
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

              // --- IMAGE (วงกลม CircleAvatar) ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 65,
                      backgroundColor: Colors.grey.shade200,
                      child: const Icon(Icons.person, size: 70, color: Colors.grey),
                    ),
                    GestureDetector(
                      onTap: _pickImage, // กดแล้วเรียกฟังก์ชันเลือกรูป
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
                      ),
                    ),
                  ],
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                  child: const Text(
                    "LOG OUT",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // วิดเจ็ตย่อยสำหรับสร้างแถวข้อมูล พร้อมรองรับปุ่มแก้ไข (Edit)
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
          IconButton(
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined, color: primaryColor),
          ),
      ],
    );
  }
}