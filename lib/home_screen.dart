import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังสีขาว
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ส่วนที่ 1: Header (TO DO LIST) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "TO DO LIST",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF8966), // สีส้มพีช
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // --- ส่วนที่ 2: Sub-Header (LIST OF TODO) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.list_alt, color: Color(0xFFFF5555), size: 30),
                      SizedBox(width: 10),
                      Text(
                        "LIST OF TODO",
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF5555), // สีแดงเข้ม
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.filter_alt_outlined, color: Color(0xFFFF5555), size: 28),
                ],
              ),

              const SizedBox(height: 20),

              // --- ส่วนที่ 3: List รายการงาน (ใช้ ListView) ---
              Expanded(
                child: ListView(
                  children: const [
                    // การ์ดใบที่ 1 (สีแดง)
                    TodoCard(
                      title: "Design Logo",
                      description: "Make logo for the mini project",
                      date: "Created at 1 Sept 2021",
                      color: Color(0xFFFF5555),
                    ),

                    // การ์ดใบที่ 2 (สีส้ม)
                    TodoCard(
                      title: "Make UI Design",
                      description: "Make UI design for the mini project post figma link...",
                      date: "Created at 1 Sept 2021",
                      color: Color(0xFFFF9E80),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      // --- ส่วนที่ 4: ปุ่มบวก (FAB) ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // ใส่โค้ดกดปุ่มบวกตรงนี้
        },
        backgroundColor: const Color(0xFFFF5555), // สีแดง
        shape: const CircleBorder(), // ทำให้กลมดิก
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
    );
  }
}

// --- Widget การ์ดแยกออกมา (เพื่อให้โค้ดดูง่าย) ---
class TodoCard extends StatelessWidget {
  final String title;
  final String description;
  final String date;
  final Color color;

  const TodoCard({
    super.key,
    required this.title,
    required this.description,
    required this.date,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15), // เว้นระยะห่างด้านล่าง
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20), // มุมโค้ง
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.access_time, color: Colors.white70),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis, // ถ้าข้อความยาวไปให้ตัด ...
          ),
          const Spacer(), // ดันวันที่ลงไปล่างสุด
          Text(
            date,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}