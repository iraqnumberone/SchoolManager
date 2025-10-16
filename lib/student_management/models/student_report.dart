import 'package:flutter/material.dart';
import 'package:school_app/student_management/models/student.dart';
import 'package:school_app/student_management/models/attendance.dart';
import 'package:school_app/student_management/models/grade.dart';

class StudentReport {
  final Student student;
  final Map<String, dynamic> attendanceStats;
  final Map<String, dynamic> gradeStats;
  final List<Attendance> recentAttendance;
  final List<Grade> recentGrades;
  final double overallScore;
  final String evaluation;

  StudentReport({
    required this.student,
    required this.attendanceStats,
    required this.gradeStats,
    required this.recentAttendance,
    required this.recentGrades,
    required this.overallScore,
    required this.evaluation,
  });

  // إنشاء تقرير طالب من JSON
  factory StudentReport.fromJson(Map<String, dynamic> json) {
    return StudentReport(
      student: Student.fromJson(json['student']),
      attendanceStats: json['attendanceStats'],
      gradeStats: json['gradeStats'],
      recentAttendance: (json['recentAttendance'] as List)
          .map((a) => Attendance.fromJson(a))
          .toList(),
      recentGrades: (json['recentGrades'] as List)
          .map((g) => Grade.fromJson(g))
          .toList(),
      overallScore: (json['overallScore'] as num).toDouble(),
      evaluation: json['evaluation'],
    );
  }

  // تحويل التقرير إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'attendanceStats': attendanceStats,
      'gradeStats': gradeStats,
      'recentAttendance': recentAttendance.map((a) => a.toJson()).toList(),
      'recentGrades': recentGrades.map((g) => g.toJson()).toList(),
      'overallScore': overallScore,
      'evaluation': evaluation,
    };
  }

  // حساب نسبة الحضور
  double get attendanceRate {
    return attendanceStats['attendanceRate'] ?? 0.0;
  }

  // حساب متوسط الدرجات
  double get gradeAverage {
    return gradeStats['overallAverage'] ?? 0.0;
  }

  // الحصول على مستوى الأداء العام
  String get performanceLevel {
    return gradeStats['performanceLevel'] ?? 'غير محدد';
  }

  // الحصول على لون التقييم العام
  Color getEvaluationColor() {
    final score = overallScore;
    if (score >= 90) return const Color(0xFF059669); // أخضر داكن - ممتاز
    if (score >= 80) return const Color(0xFF10B981); // أخضر فاتح - جيد جداً
    if (score >= 70) return const Color(0xFFF59E0B); // برتقالي - جيد
    if (score >= 60) return const Color(0xFFF97316); // برتقالي داكن - مقبول
    return const Color(0xFFEF4444); // أحمر - ضعيف
  }

  // الحصول على أيقونة التقييم العام
  IconData getEvaluationIcon() {
    final score = overallScore;
    if (score >= 90) return Icons.star;
    if (score >= 80) return Icons.thumb_up;
    if (score >= 70) return Icons.check_circle;
    if (score >= 60) return Icons.info;
    return Icons.warning;
  }

  // الحصول على نص التقييم العام باللغة العربية
  String getEvaluationText() {
    final score = overallScore;
    if (score >= 90) return 'ممتاز جداً';
    if (score >= 80) return 'ممتاز';
    if (score >= 70) return 'جيد';
    if (score >= 60) return 'مقبول';
    return 'يحتاج تحسين';
  }

  @override
  String toString() {
    return 'StudentReport(student: ${student.fullName}, overallScore: $overallScore, evaluation: $evaluation)';
  }
}
