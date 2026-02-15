import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_todo_screen.dart'; // import หน้ารายละเอียด

class NewHomeScreen extends StatefulWidget {
  const NewHomeScreen({super.key});

  @override
  State<NewHomeScreen> createState() => _NewHomeScreenState();
}

class _NewHomeScreenState extends State<NewHomeScreen> {
  final CollectionReference todoCollection = FirebaseFirestore.instance.collection('todos');

  final List<Color> cardColors = [
    const Color(0xFFFF5555), // แดง
    const Color(0xFFFF9E80), // ส้มพีช
    const Color(0xFFFFCC80), // เหลืองอ่อน
    const Color(0xFF80CBC4), // เขียวมิ้นต์
  ];

  // ฟังก์ชันเพิ่มงานลง Firebase
  void _addNewTask(String title, String description, DateTime? deadline) {
    todoCollection.add({
      'title': title,
      'description': description,
      'deadline': deadline != null ? Timestamp.fromDate(deadline) : null,
      'isCompleted': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ฟังก์ชันติ๊กถูก (Update)
  void _toggleTask(String id, bool currentStatus) {
    todoCollection.doc(id).update({'isCompleted': !currentStatus});
  }

  // ฟังก์ชันลบงาน (Delete)
  void _deleteTask(String id) {
    todoCollection.doc(id).delete();
  }

  // เปิดหน้าต่างเพิ่มงาน (Bottom Sheet)
  void _openAddTodoSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTodoSheet(),
    ).then((value) {
      if (value != null && value is Map<String, dynamic>) {
        _addNewTask(
            value['title'],
            value['description'],
            value['deadline']
        );
      }
    });
  }

  // แปลงวันที่เป็นข้อความ
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return "No Deadline";
    DateTime date = timestamp.toDate();
    return "${date.day}/${date.month}/${date.year}";
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
            // หัวข้อ LIST OF TODO
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

            // --- ส่วนที่ 1: การ์ดแนวนอน ---
            SizedBox(
              height: 160,
              child: StreamBuilder(
                stream: todoCollection.orderBy('timestamp', descending: true).snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) return const Center(child: Text("ยังไม่มีงาน.. กดปุ่ม + เลย!"));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final docId = docs[index].id;

                      final title = data['title'] ?? 'No Title';
                      final description = data['description'] ?? '';
                      final color = cardColors[index % cardColors.length];

                      final deadlineTimestamp = data['deadline'] as Timestamp?;
                      final dateText = _formatDate(deadlineTimestamp);

                      return Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: GestureDetector(
                          onTap: () {
                            // ไปหน้า Detail พร้อมส่ง ID
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailTodoScreen(
                                  docId: docId,
                                  title: title,
                                  description: description,
                                  timestamp: data['timestamp'],
                                ),
                              ),
                            );
                          },
                          child: ProjectCard(
                            title: title,
                            subtitle: description.isEmpty ? "No Description" : description,
                            date: dateText,
                            color: color,
                            icon: Icons.calendar_today,
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
        onPressed: _openAddTodoSheet,
        backgroundColor: const Color(0xFFFF5555),
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }
}

// --- WIDGET: หน้าต่างเพิ่มงาน (สีส้ม) ---
class AddTodoSheet extends StatefulWidget {
  const AddTodoSheet({super.key});

  @override
  State<AddTodoSheet> createState() => _AddTodoSheetState();
}

class _AddTodoSheetState extends State<AddTodoSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  DateTime? _selectedDate;

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFFF5555),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFFF9E80),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
      child: Column(
        children: [
          Container(width: 50, height: 5, decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 30),
          _buildTextField(controller: _titleController, hint: "Title"),
          const SizedBox(height: 20),
          _buildTextField(controller: _descController, hint: "Description", maxLines: 6),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _pickDate,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.5), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  Expanded(child: Text(_selectedDate == null ? "Deadline (Optional)" : "Selected: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}", style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))),
                  const Icon(Icons.calendar_today_outlined, color: Colors.white),
                ],
              ),
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  Navigator.pop(context, {
                    'title': _titleController.text,
                    'description': _descController.text,
                    'deadline': _selectedDate,
                  });
                }
              },
              child: const Text("ADD TODO", style: TextStyle(color: Color(0xFFFF9E80), fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 18),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Colors.white, width: 2)),
      ),
    );
  }
}

// --- WIDGETS ย่อย ---
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)), Icon(icon, color: Colors.white70, size: 20)]),
          const SizedBox(height: 8),
          Text(subtitle.isEmpty ? "No Description" : subtitle, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
          const Spacer(),
          Text(date, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
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