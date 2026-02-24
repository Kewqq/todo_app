import 'package:cloud_firestore/cloud_firestore.dart';

class TodoModel {
  final String id;           // ไอดีประจำเอกสาร
  final String title;        // หัวข้อภารกิจ
  final String description;  // รายละเอียด
  final bool isCompleted;    // สถานะการเสร็จสิ้น
  final String uid;          // รหัสผู้เป็นเจ้าของข้อมูล
  final Timestamp? timestamp; // เวลาที่สร้างข้อมูล
  final Timestamp? deadline;  // วันที่ครบกำหนด

  TodoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.uid,
    this.timestamp,
    this.deadline,
  });

  // ฟังก์ชัน Factory สำหรับแปลงข้อมูลจาก Firebase (Map) ให้เป็น Object ในภาษา Dart
  factory TodoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return TodoModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      isCompleted: data['isCompleted'] ?? false,
      uid: data['uid'] ?? '',
      timestamp: data['timestamp'],
      deadline: data['deadline'],
    );
  }

  // ฟังก์ชันสำหรับแปลง Object ให้กลับเป็น Map เพื่อส่งไปบันทึกบนฐานข้อมูล
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'uid': uid,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'deadline': deadline,
    };
  }
}