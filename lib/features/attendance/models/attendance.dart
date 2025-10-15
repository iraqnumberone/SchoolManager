import 'package:flutter/material.dart';

class Attendance {
  final String id;
  final String studentId;
  final String classroomId;
  final String schoolId;
  final DateTime date;
  final String status; // present, absent, excused, late, sick
  final String checkInTime;
  final String? checkOutTime;
  final String recordedBy; // معرف المعلم الذي سجل الحضور
  final String? notes;
  final String? location; // موقع تسجيل الحضور (GPS أو اسم المكان)
  final Map<String, dynamic> metadata;

  Attendance({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.schoolId,
    required this.date,
    required this.status,
    required this.checkInTime,
    this.checkOutTime,
    required this.recordedBy,
    this.notes,
    this.location,
    this.metadata = const {},
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      classroomId: json['classroomId'] as String,
      schoolId: json['schoolId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      checkInTime: json['checkInTime'] as String,
      checkOutTime: json['checkOutTime'] as String?,
      recordedBy: json['recordedBy'] as String,
      notes: json['notes'] as String?,
      location: json['location'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'classroomId': classroomId,
      'schoolId': schoolId,
      'date': date.toIso8601String(),
      'status': status,
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'recordedBy': recordedBy,
      'notes': notes,
      'location': location,
      'metadata': metadata,
    };
  }

  Attendance copyWith({
    String? id,
    String? studentId,
    String? classroomId,
    String? schoolId,
    DateTime? date,
    String? status,
    String? checkInTime,
    String? checkOutTime,
    String? recordedBy,
    String? notes,
    String? location,
    Map<String, dynamic>? metadata,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classroomId: classroomId ?? this.classroomId,
      schoolId: schoolId ?? this.schoolId,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      recordedBy: recordedBy ?? this.recordedBy,
      notes: notes ?? this.notes,
      location: location ?? this.location,
      metadata: metadata ?? this.metadata,
    );
  }

  Color get statusColor {
    switch (status) {
      case 'present': return const Color(0xFF7ED321); // أخضر فاتح
      case 'absent': return const Color(0xFFF8E71C); // أصفر فاتح
      case 'excused': return const Color(0xFF50A6E3); // أزرق فاتح
      case 'late': return const Color(0xFFF5A623); // برتقالي
      case 'sick': return const Color(0xFFD0021B); // أحمر
      default: return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 'present': return Icons.check_circle;
      case 'absent': return Icons.cancel;
      case 'excused': return Icons.info;
      case 'late': return Icons.schedule;
      case 'sick': return Icons.local_hospital;
      default: return Icons.help;
    }
  }

  String get statusText {
    switch (status) {
      case 'present': return 'حاضر';
      case 'absent': return 'غائب';
      case 'excused': return 'مجاز';
      case 'late': return 'متأخر';
      case 'sick': return 'مريض';
      default: return 'غير محدد';
    }
  }

  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
           date.month == today.month &&
           date.day == today.day;
  }

  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
           date.isBefore(weekEnd.add(const Duration(days: 1)));
  }

  bool get isThisMonth {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  @override
  String toString() {
    return 'Attendance(id: $id, studentId: $studentId, date: $date, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Attendance &&
           other.studentId == studentId &&
           other.date == date &&
           other.classroomId == classroomId;
  }

  @override
  int get hashCode => Object.hash(studentId, date, classroomId);
}
