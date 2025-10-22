class ClassGroup {
  final String id;
  final String schoolId;
  final String stageId;
  final String name;
  final String? description;
  final int capacity;
  final int currentStudents;
  final String? teacherId;
  final String teacherName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassGroup({
    required this.id,
    required this.schoolId,
    required this.stageId,
    required this.name,
    this.description,
    required this.capacity,
    this.currentStudents = 0,
    this.teacherId,
    this.teacherName = 'غير محدد',
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    updatedAt = updatedAt ?? DateTime.now();

  // إنشاء شعبة من JSON
  factory ClassGroup.fromJson(Map<String, dynamic> json) {
    return ClassGroup(
      id: json['id'].toString(),
      schoolId: json['schoolId'].toString(),
      stageId: json['stageId'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      currentStudents: json['current_students'] is int ? json['current_students'] : int.tryParse(json['current_students']?.toString() ?? '0') ?? 0,
      teacherId: json['teacher_id']?.toString(),
      teacherName: json['teacher_name']?.toString() ?? 'غير محدد',
      isActive: json['is_active'] == true || (json['is_active'] is int && json['is_active'] == 1),
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'].toString()) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'].toString()) : null,
    );
  }

  // تحويل الشعبة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'school_id': schoolId,
      'stage_id': stageId,
      'name': name,
      'description': description,
      'capacity': capacity,
      'current_students': currentStudents,
      'teacher_id': teacherId,
      'teacher_name': teacherName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
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
    int? currentStudents,
    String? teacherId,
    String? teacherName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassGroup(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      stageId: stageId ?? this.stageId,
      name: name ?? this.name,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      currentStudents: currentStudents ?? this.currentStudents,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // حساب نسبة الامتلاء
  double get occupancyRate => capacity > 0 ? currentStudents / capacity : 0;

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
