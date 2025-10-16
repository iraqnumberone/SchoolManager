import 'package:flutter/material.dart';

class Grade {
  final String id;
  final String studentId;
  final String schoolId;
  final String subject;
  final String gradeType; // daily, monthly, midterm, final
  final double score;
  final double maxScore;
  final DateTime date;
  final String recordedBy;
  final DateTime recordedAt;
  final String? notes;
  final Map<String, dynamic>? additionalData;

  Grade({
    required this.id,
    required this.studentId,
    required this.schoolId,
    required this.subject,
    required this.gradeType,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.recordedBy,
    required this.recordedAt,
    this.notes,
    this.additionalData,
  });

  // إنشاء درجة من JSON
  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      schoolId: json['schoolId'] as String,
      subject: json['subject'] as String,
      gradeType: json['gradeType'] as String,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      recordedBy: json['recordedBy'] as String,
      recordedAt: DateTime.parse(json['recordedAt'] as String),
      notes: json['notes'] as String?,
      additionalData: json['additionalData'] as Map<String, dynamic>?,
    );
  }

  // تحويل الدرجة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'schoolId': schoolId,
      'subject': subject,
      'gradeType': gradeType,
      'score': score,
      'maxScore': maxScore,
      'date': date.toIso8601String(),
      'recordedBy': recordedBy,
      'recordedAt': recordedAt.toIso8601String(),
      'notes': notes,
      'additionalData': additionalData,
    };
  }

  // نسخ الدرجة مع تعديلات
  Grade copyWith({
    String? id,
    String? studentId,
    String? schoolId,
    String? subject,
    String? gradeType,
    double? score,
    double? maxScore,
    DateTime? date,
    String? recordedBy,
    DateTime? recordedAt,
    String? notes,
    Map<String, dynamic>? additionalData,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      schoolId: schoolId ?? this.schoolId,
      subject: subject ?? this.subject,
      gradeType: gradeType ?? this.gradeType,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      date: date ?? this.date,
      recordedBy: recordedBy ?? this.recordedBy,
      recordedAt: recordedAt ?? this.recordedAt,
      notes: notes ?? this.notes,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  // حساب النسبة المئوية
  double get percentage {
    if (maxScore == 0) return 0.0;
    return (score / maxScore) * 100;
  }

  // الحصول على مستوى الأداء
  String getPerformanceLevel() {
    final percent = percentage;
    if (percent >= 90) return 'ممتاز';
    if (percent >= 80) return 'جيد جداً';
    if (percent >= 70) return 'جيد';
    if (percent >= 60) return 'مقبول';
    return 'ضعيف';
  }

  // الحصول على لون مستوى الأداء
  Color getPerformanceColor() {
    final percent = percentage;
    if (percent >= 90) return const Color(0xFF059669); // أخضر داكن
    if (percent >= 80) return const Color(0xFF10B981); // أخضر فاتح
    if (percent >= 70) return const Color(0xFFF59E0B); // برتقالي
    if (percent >= 60) return const Color(0xFFF97316); // برتقالي داكن
    return const Color(0xFFEF4444); // أحمر
  }

  // الحصول على نص نوع الدرجة باللغة العربية
  String getGradeTypeText() {
    switch (gradeType) {
      case 'daily':
        return 'درجة يومية';
      case 'monthly':
        return 'درجة شهرية';
      case 'midterm':
        return 'درجة منتصف الفصل';
      case 'final':
        return 'درجة نهائية';
      default:
        return gradeType;
    }
  }

  // التحقق من هل الدرجة حديثة (خلال الأسبوع الماضي)
  bool get isRecent {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  String get shortInfo {
    return '$subject: ${score.toStringAsFixed(1)}/$maxScore (${percentage.toStringAsFixed(1)}%)';
  }

  @override
  String toString() {
    return 'Grade(id: $id, studentId: $studentId, subject: $subject, score: $score/$maxScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grade &&
           other.studentId == studentId &&
           other.subject == subject &&
           other.date == date;
  }

  @override
  int get hashCode => Object.hash(studentId, subject, date);
}
