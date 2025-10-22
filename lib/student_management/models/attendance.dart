import 'package:flutter/material.dart';

class Attendance {
  final String id;
  final String studentId;
  final String schoolId;
  final DateTime date;
  final String status; // present, absent, excused, late
  final String? notes;
  final String recordedBy;
  final DateTime recordedAt;
  final String? checkInTime;
  final String? checkOutTime;
  final Map<String, dynamic>? additionalData;

  Attendance({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.date,
    required this.status,
    this.notes,
    required this.recordedBy,
    required this.recordedAt,
    this.checkInTime,
    this.checkOutTime,
    this.additionalData,
  });

  // إنشاء سجل حضور من JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      schoolId: json['schoolId'] as String,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      recordedBy: json['recordedBy'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      checkInTime: json['checkInTime'] as String?,
      checkOutTime: json['checkOutTime'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  // تحويل سجل الحضور إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'schoolId': schoolId,
      'date': date.toIso8601String(),
      'status': status,
      'notes': notes,
      'recordedBy': recordedBy,
      'recordedAt': recordedAt.toIso8601String(),
      'checkInTime': checkInTime,
      'checkOutTime': checkOutTime,
      'additionalData': additionalData,
    };
  }

  // نسخ سجل الحضور مع تعديلات
  Attendance copyWith({
    String? id,
    String? studentId,
    String? schoolId,
    DateTime? date,
    String? status,
    String? notes,
    String? recordedBy,
    DateTime? recordedAt,
    String? checkInTime,
    String? checkOutTime,
    Map<String, dynamic>? additionalData,
  }) {
    return Attendance(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
      date: date ?? this.date,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedAt: recordedAt ?? this.recordedAt,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // الحصول على لون الحالة
  Color getStatusColor() {
    switch (status) {
      case 'present':
        return const Color(0xFF10B981); // أخضر
      case 'absent':
        return const Color(0xFFEF4444); // أحمر
      case 'excused':
        return const Color(0xFFF59E0B); // برتقالي
      case 'late':
        return const Color(0xFF8B5CF6); // بنفسجي
      default:
        return const Color(0xFF6B7280); // رمادي
    }
  }

  // الحصول على أيقونة الحالة
  IconData getStatusIcon() {
    switch (status) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'excused':
        return Icons.info;
      case 'late':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  // الحصول على نص الحالة باللغة العربية
  String getStatusText() {
    switch (status) {
      case 'present':
        return 'حاضر';
      case 'absent':
        return 'غائب';
      case 'excused':
        return 'مجاز';
      case 'late':
        return 'متأخر';
      default:
        return 'غير محدد';
    }
  }

  // التحقق من هل السجل لليوم الحالي
  bool get isToday {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  // التحقق من هل السجل لهذا الأسبوع
  bool get isThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
        date.isBefore(weekEnd.add(const Duration(days: 1)));
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
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(studentId, date);
}
