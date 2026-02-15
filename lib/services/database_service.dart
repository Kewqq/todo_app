import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // import เพิ่ม

class DatabaseService {
  final CollectionReference todoCollection =
  FirebaseFirestore.instance.collection('todos');

  // ดึง User ID ของคนที่ล็อกอินอยู่ปัจจุบัน
  String? get uid => FirebaseAuth.instance.currentUser?.uid;

  // 1. CREATE: เพิ่มงาน (โดยแปะ uid ไปด้วย)
  Future<void> addTodo(String title) async {
    if (uid == null) return; // ถ้าไม่ได้ล็อกอิน ไม่ให้ทำ

    await todoCollection.add({
      'title': title,
      'isCompleted': false,
      'timestamp': FieldValue.serverTimestamp(),
      'uid': uid, // <--- สำคัญ! ระบุเจ้าของงาน
    });
  }

  // 2. READ: ดึงข้อมูล (เฉพาะที่เป็นของ uid นี้)
  Stream<QuerySnapshot> getTodos() {
    if (uid == null) return const Stream.empty();

    return todoCollection
        .where('uid', isEqualTo: uid) // <--- สำคัญ! กรองเอาเฉพาะของฉัน
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // 3. UPDATE & DELETE ใช้เหมือนเดิม เพราะเราอ้างอิงจาก Doc ID
  Future<void> updateTodoStatus(String id, bool currentStatus) async {
    return await todoCollection.doc(id).update({'isCompleted': !currentStatus});
  }

  Future<void> deleteTodo(String id) async {
    return await todoCollection.doc(id).delete();
  }
}