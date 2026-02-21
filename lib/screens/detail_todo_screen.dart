import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailTodoScreen extends StatefulWidget {
  final String docId;
  final String title;
  final String description;
  final Timestamp? timestamp;

  const DetailTodoScreen({
    super.key,
    required this.docId,
    required this.title,
    required this.description,
    this.timestamp,
  });

  @override
  State<DetailTodoScreen> createState() => _DetailTodoScreenState();
}

class _DetailTodoScreenState extends State<DetailTodoScreen> {
  late String currentTitle;
  late String currentDesc;

  @override
  void initState() {
    super.initState();
    currentTitle = widget.title;
    currentDesc = widget.description;
  }

  void _deleteTask() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm delete🗑️"),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              FirebaseFirestore.instance.collection('todos').doc(widget.docId).delete();
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editTask() {
    TextEditingController titleController = TextEditingController(text: currentTitle);
    TextEditingController descController = TextEditingController(text: currentDesc);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit 📝"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, decoration: const InputDecoration(labelText: "Topic name")),
            const SizedBox(height: 10),
            TextField(controller: descController, decoration: const InputDecoration(labelText: "detail"), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5555)),
            onPressed: () {
              FirebaseFirestore.instance.collection('todos').doc(widget.docId).update({
                'title': titleController.text,
                'description': descController.text,
              });
              setState(() {
                currentTitle = titleController.text;
                currentDesc = descController.text;
              });
              Navigator.pop(context);
            },
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String dateText = "Unknown Date";
    if (widget.timestamp != null) {
      DateTime date = widget.timestamp!.toDate();
      List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      dateText = "Created at ${date.day} ${months[date.month - 1]} ${date.year}";
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black), onPressed: () => Navigator.pop(context)),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined, color: Colors.black), onPressed: _editTask),
          IconButton(icon: const Icon(Icons.delete_outline, color: Colors.black), onPressed: _deleteTask),
          const SizedBox(width: 10),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(currentTitle.toUpperCase(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black)),
            const SizedBox(height: 30),
            Text(currentDesc.isEmpty ? "No Description provided." : currentDesc, style: const TextStyle(fontSize: 16, color: Colors.black54, height: 1.6)),
            const Spacer(),
            Center(child: Text(dateText, style: const TextStyle(color: Colors.grey, fontSize: 14))),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}