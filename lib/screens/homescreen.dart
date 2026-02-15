import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product_details_screen.dart'; // อย่าลืม import หน้านี้

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final CollectionReference todoCollection = FirebaseFirestore.instance.collection('todos');

  // ชุดสีเอาไว้สลับกันเวลาแสดงการ์ด
  final List<Color> cardColors = [
    const Color(0xFFFF5555), // แดง
    const Color(0xFFFF9E80), // ส้มพีช
    const Color(0xFFFFCC80), // เหลืองอ่อน
    const Color(0xFF80CBC4), // เขียวมิ้นต์
  ];

  void _addNewTask(String title) {
    todoCollection.add({
      'title': title,
      'isCompleted': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  void _toggleTask(String id, bool currentStatus) {
    todoCollection.doc(id).update({'isCompleted': !currentStatus});
  }

  void _deleteTask(String id) {
    todoCollection.doc(id).delete();
  }

  void _showAddDialog() {
    String newTaskTitle = "";
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("เพิ่มงานใหม่ 📝"),
        content: TextField(
          autofocus: true,
          onChanged: (value) => newTaskTitle = value,
          decoration: const InputDecoration(hintText: "พิมพ์ชื่องานที่นี่..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ยกเลิก")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5555)),
            onPressed: () {
              if (newTaskTitle.isNotEmpty) {
                _addNewTask(newTaskTitle);
                Navigator.pop(context);
              }
            },
            child: const Text("บันทึก", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("TO DO LIST",
            style: TextStyle(color: Color(0xFFFF8966), fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black54), onPressed: () {}),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.list_alt, color: Color(0xFFFF5555), size: 28),
                    SizedBox(width: 8),
                    Text("LIST OF TODO",
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF5555))),
                  ],
                ),
                const Icon(Icons.filter_alt_outlined, color: Color(0xFFFF5555)),
              ],
            ),
            const SizedBox(height: 20),

            // --- ส่วนที่ 1: การ์ดแนวนอน (แก้ Error ตรงนี้ให้แล้ว) ---
            SizedBox(
              height: 160,
              child: StreamBuilder(
                stream: todoCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(child: Text("กดปุ่ม + เพื่อเพิ่มงานแรกของคุณ"));
                  }

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final title = data['title'] ?? 'No Title';
                      final color = cardColors[index % cardColors.length];

                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        // ห่อด้วย GestureDetector เพื่อให้กดแล้วไปหน้าสินค้า
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const ProductDetailsScreen()),
                            );
                          },
                          // ใส่ข้อมูล ProjectCard ให้ครบถ้วน (แก้ Error missing arguments)
                          child: ProjectCard(
                            title: title,
                            subtitle: "Priority Task #${index + 1}",
                            date: "Just Now",
                            color: color,
                            icon: Icons.work_outline,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
            const Text("TASKS FOR TODAY", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 10),

            // --- ส่วนที่ 2: รายการแนวตั้ง ---
            Expanded(
              child: StreamBuilder(
                stream: todoCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final task = docs[index];
                      final data = task.data() as Map<String, dynamic>;
                      return TaskTile(
                        title: data['title'] ?? '',
                        isCompleted: data['isCompleted'] ?? false,
                        onTap: () => _toggleTask(task.id, data['isCompleted']),
                        onLongPress: () => _deleteTask(task.id),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: const Color(0xFFFF5555),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

// --- WIDGETS ---

class ProjectCard extends StatelessWidget {
  final String title, subtitle, date;
  final Color color;
  final IconData icon;
  const ProjectCard({super.key, required this.title, required this.subtitle, required this.date, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
            Icon(icon, color: Colors.white70, size: 20)
          ]),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(date, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const TaskTile({super.key, required this.title, required this.isCompleted, required this.onTap, required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: ListTile(
          leading: Icon(isCompleted ? Icons.check_circle : Icons.radio_button_unchecked, color: isCompleted ? const Color(0xFFFF5555) : Colors.grey),
          title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: isCompleted ? Colors.grey : Colors.black87, decoration: isCompleted ? TextDecoration.lineThrough : null)),
          trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.grey), onPressed: onLongPress),
        ),
      ),
    );
  }
}