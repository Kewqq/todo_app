import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  // อ้างอิงถึง Collection (ตารางเก็บข้อมูล) ชื่อ 'todos'
  final CollectionReference todoCollection =
  FirebaseFirestore.instance.collection('todos');

  // 1. CREATE: เพิ่มงานใหม่
  Future<void> addTodo(String title) async {
    return await todoCollection.add({
      'title': title,
      'isCompleted': false,
      'timestamp': FieldValue.serverTimestamp(), // เก็บเวลาเพื่อใช้เรียงลำดับ
    });
  }

  // 2. READ: ดึงข้อมูลแบบ Stream (Real-time update)
  Stream<QuerySnapshot> getTodos() {
    return todoCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // 3. UPDATE: อัพเดทสถานะ (ติ๊กถูก/เอาออก)
  Future<void> updateTodoStatus(String id, bool currentStatus) async {
    return await todoCollection.doc(id).update({
      'isCompleted': !currentStatus,
    });
  }

  // 4. DELETE: ลบงาน
  Future<void> deleteTodo(String id) async {
    return await todoCollection.doc(id).delete();
  }
}