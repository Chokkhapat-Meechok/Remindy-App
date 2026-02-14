class Reminder {
  final String id;
  String title;
  DateTime time;
  String type;
  bool isDone;

  Reminder({
    required this.id,
    required this.title,
    required this.time,
    required this.type,
    this.isDone = false,
  });
}
