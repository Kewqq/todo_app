import 'package:flutter/material.dart';

class TodoTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final Function(bool?)? onChanged;

  const TodoTile({
    super.key,
    required this.title,
    required this.isDone,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      leading: Checkbox(
        value: isDone,
        onChanged: onChanged,
      ),
    );
  }
}
