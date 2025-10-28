class StudentModel {
  final int? id;
  final String name;
  final String? gender; // M/F or text
  final String? stage; // e.g., primary/secondary
  final String? classGroup; // e.g., A, B
  final int? createdAt;

  StudentModel({
    this.id,
    required this.name,
    this.gender,
    this.stage,
    this.classGroup,
    this.createdAt,
  });

  StudentModel copyWith({
    int? id,
    String? name,
    String? gender,
    String? stage,
    String? classGroup,
    int? createdAt,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender ?? this.gender,
      stage: stage ?? this.stage,
      classGroup: classGroup ?? this.classGroup,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'gender': gender,
    'stage': stage,
    'class_group': classGroup,
    'created_at': createdAt,
  };

  factory StudentModel.fromMap(Map<String, Object?> map) => StudentModel(
    id: map['id'] as int?,
    name: (map['name'] ?? '') as String,
    gender: map['gender'] as String?,
    stage: map['stage'] as String?,
    classGroup: map['class_group'] as String?,
    createdAt: map['created_at'] as int?,
  );
}
