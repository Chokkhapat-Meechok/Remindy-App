class Reminder {
  final String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? dueAt;
  String type;
  bool isCompleted;
  bool isDeleted;

  Reminder({
    required this.id,
    required this.title,
    this.description = '',
    DateTime? createdAt,
    this.dueAt,
    required this.type,
    this.isCompleted = false,
    this.isDeleted = false,
  }) : createdAt = createdAt ?? DateTime.now();

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      dueAt: json['dueAt'] != null
          ? DateTime.tryParse(json['dueAt'] as String)
          : null,
      type: json['type'] as String? ?? 'Personal',
      isCompleted: json['isCompleted'] as bool? ?? false,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'createdAt': createdAt.toIso8601String(),
    'dueAt': dueAt?.toIso8601String(),
    'type': type,
    'isCompleted': isCompleted,
    'isDeleted': isDeleted,
  };
}
