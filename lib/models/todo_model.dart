class TodoModel {
  final String id;
  final String title;
  final bool isDone;

  TodoModel({
    required this.id,
    required this.title,
    this.isDone = false,
  });
}
