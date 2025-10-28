import 'package:flutter/material.dart';

class Classroom {
  final String id;
  final String name;
  final String nameEn;
  final String schoolId;
  final String stageId;
  final String grade; // الصف الدراسي (الأول، الثاني، إلخ)
  final String section; // الشعبة (أ، ب، ج، إلخ)
  final String? classTeacherId;
  final String? assistantTeacherId;
  final int maxStudents;
  final int currentStudents;
  final String academicYear;
  final String roomNumber;
  final String schedule; // JSON string للجدول الزمني
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Classroom({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.schoolId,
    required this.stageId,
    required this.grade,
    required this.section,
    this.classTeacherId,
    this.assistantTeacherId,
    this.maxStudents = 30,
    this.currentStudents = 0,
    required this.academicYear,
    this.roomNumber = '',
    this.schedule = '',
    this.settings = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      schoolId: json['schoolId'] as String,
      stageId: json['stageId'] as String,
      grade: json['grade'] as String,
      section: json['section'] as String,
      classTeacherId: json['classTeacherId'] as String?,
      assistantTeacherId: json['assistantTeacherId'] as String?,
      maxStudents: json['maxStudents'] as int? ?? 30,
      currentStudents: json['currentStudents'] as int? ?? 0,
      academicYear: json['academicYear'] as String,
      roomNumber: json['roomNumber'] as String? ?? '',
      schedule: json['schedule'] as String? ?? '',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'schoolId': schoolId,
      'stageId': stageId,
      'grade': grade,
      'section': section,
      'classTeacherId': classTeacherId,
      'assistantTeacherId': assistantTeacherId,
      'maxStudents': maxStudents,
      'currentStudents': currentStudents,
      'academicYear': academicYear,
      'roomNumber': roomNumber,
      'schedule': schedule,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Classroom copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? schoolId,
    String? stageId,
    String? grade,
    String? section,
    String? classTeacherId,
    String? assistantTeacherId,
    int? maxStudents,
    int? currentStudents,
    String? academicYear,
    String? roomNumber,
    String? schedule,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Classroom(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      schoolId: schoolId ?? this.schoolId,
      stageId: stageId ?? this.stageId,
      grade: grade ?? this.grade,
      section: section ?? this.section,
      classTeacherId: classTeacherId ?? this.classTeacherId,
      assistantTeacherId: assistantTeacherId ?? this.assistantTeacherId,
      maxStudents: maxStudents ?? this.maxStudents,
      currentStudents: currentStudents ?? this.currentStudents,
      academicYear: academicYear ?? this.academicYear,
      roomNumber: roomNumber ?? this.roomNumber,
      schedule: schedule ?? this.schedule,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayName => '$grade$section';
  String get fullName => '$name ($grade$section)';
  String get capacityStatus {
    if (currentStudents >= maxStudents) return 'مكتملة';
    if (currentStudents >= maxStudents * 0.9) return 'شبه مكتملة';
    return 'متاحة';
  }

  Color get capacityColor {
    if (currentStudents >= maxStudents) return Colors.red;
    if (currentStudents >= maxStudents * 0.9) return Colors.orange;
    return Colors.green;
  }

  double get capacityPercentage =>
      maxStudents > 0 ? (currentStudents / maxStudents) * 100 : 0.0;

  bool get isFull => currentStudents >= maxStudents;
  bool get hasSpace => currentStudents < maxStudents;

  @override
  String toString() {
    return 'Classroom(id: $id, name: $name, grade: $grade$section)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Classroom && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
