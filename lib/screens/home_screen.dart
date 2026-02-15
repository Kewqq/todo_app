import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService(); // เรียกใช้ Backend
  final TextEditingController _textController = TextEditingController();

  // ฟังก์ชันเปิด Dialog เพื่อเพิ่มงาน
  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('เพิ่มงานใหม่'),
        content: TextField(
          controller: _textController,
          decoration: const InputDecoration(hintText: "สิ่งที่ต้องทำ..."),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.isNotEmpty) {
                _databaseService.addTodo(_textController.text); // ส่งข้อมูลไป Firebase
                _textController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('To-Do List (Firebase)')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _databaseService.getTodos(), // ฟังข้อมูลจาก Backend
        builder: (context, snapshot) {
          // กรณีโหลดข้อมูลหรือมี Error
          if (snapshot.hasError) return const Center(child: Text('เกิดข้อผิดพลาด'));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // ดึงข้อมูลออกมาเป็น List
          final todos = snapshot.data!.docs;

          if (todos.isEmpty) return const Center(child: Text('ยังไม่มีรายการงาน'));

          return ListView.builder(
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final String docID = todo.id; // ID ของเอกสารใน Firebase
              final Map<String, dynamic> data = todo.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    data['title'],
                    style: TextStyle(
                      decoration: data['isCompleted']
                          ? TextDecoration.lineThrough // ขีดฆ่าถ้าเสร็จแล้ว
                          : null,
                    ),
                  ),
                  leading: Checkbox(
                    value: data['isCompleted'],
                    onChanged: (val) {
                      _databaseService.updateTodoStatus(docID, data['isCompleted']);
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _databaseService.deleteTodo(docID),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}