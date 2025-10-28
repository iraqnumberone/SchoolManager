class TaskModel {
  final int? id;
  final String title;
  final bool isDone;
  final int? dueDate;
  final int? createdAt;

  TaskModel({
    this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.createdAt,
  });

  TaskModel copyWith({
    int? id,
    String? title,
    bool? isDone,
    int? dueDate,
    int? createdAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'is_done': isDone ? 1 : 0,
    'due_date': dueDate,
    'created_at': createdAt,
  };

  factory TaskModel.fromMap(Map<String, Object?> map) => TaskModel(
    id: map['id'] as int?,
    title: (map['title'] ?? '') as String,
    isDone: (map['is_done'] as int? ?? 0) == 1,
    dueDate: map['due_date'] as int?,
    createdAt: map['created_at'] as int?,
  );
}
