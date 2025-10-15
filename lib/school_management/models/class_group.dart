class ClassGroup {
  final String id;
  final String schoolId;
  final String stageId;
  final String name;
  final String? description;
  final int capacity;
  final String teacherId;
  final String? teacherName;
  final bool isActive;
  final DateTime createdAt;

  ClassGroup({
    required this.id,
    required this.schoolId,
    required this.stageId,
    required this.name,
    this.description,
    required this.capacity,
    required this.teacherId,
    this.teacherName,
    this.isActive = true,
    required this.createdAt,
  });

  // إنشاء شعبة من JSON
  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      stageId: json['stageId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      capacity: json['capacity'] as int,
      teacherId: json['teacherId'] as String,
      teacherName: json['teacherName'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // تحويل الشعبة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'stageId': stageId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'teacherId': teacherId,
      'teacherName': teacherName,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // نسخ الشعبة مع تعديلات
  ClassGroup copyWith({
    String? id,
    String? schoolId,
    String? stageId,
    String? name,
    String? description,
    int? capacity,
    String? teacherId,
    String? teacherName,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return ClassGroup(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      stageId: stageId ?? this.stageId,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // حساب عدد الطلاب الحاليين في الشعبة
  int get currentStudents => 0; // سيتم حسابه من قاعدة البيانات

  // حساب نسبة الامتلاء
  double get occupancyRate => currentStudents / capacity;

  // التحقق من إمكانية إضافة طالب جديد
  bool canAddStudent() => currentStudents < capacity;

  @override
  String toString() {
    return 'ClassGroup(id: $id, name: $name, stageId: $stageId, capacity: $capacity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ClassGroup && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
