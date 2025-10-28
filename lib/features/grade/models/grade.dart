import 'package:flutter/material.dart';

class Grade {
  final String id;
  final String studentId;
  final String subjectId;
  final String classroomId;
  final String schoolId;
  final String
  gradeType; // daily, weekly, monthly, midterm, final, project, homework
  final double score;
  final double maxScore;
  final DateTime date;
  final String recordedBy;
  final String? notes;
  final String? comments;
  final Map<String, dynamic> metadata;

  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.classroomId,
    required this.schoolId,
    required this.gradeType,
    required this.score,
    required this.maxScore,
    required this.date,
    required this.recordedBy,
    this.notes,
    this.comments,
    this.metadata = const {},
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      subjectId: json['subjectId'] as String,
      classroomId: json['classroomId'] as String,
      schoolId: json['schoolId'] as String,
      gradeType: json['gradeType'] as String,
      score: (json['score'] as num).toDouble(),
      maxScore: (json['maxScore'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      recordedBy: json['recordedBy'] as String,
      notes: json['notes'] as String?,
      comments: json['comments'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'subjectId': subjectId,
      'classroomId': classroomId,
      'schoolId': schoolId,
      'gradeType': gradeType,
      'score': score,
      'maxScore': maxScore,
      'date': date.toIso8601String(),
      'recordedBy': recordedBy,
      'notes': notes,
      'comments': comments,
      'metadata': metadata,
    };
  }

  Grade copyWith({
    String? id,
    String? studentId,
    String? subjectId,
    String? classroomId,
    String? schoolId,
    String? gradeType,
    double? score,
    double? maxScore,
    DateTime? date,
    String? recordedBy,
    String? notes,
    String? comments,
    Map<String, dynamic>? metadata,
  }) {
    return Grade(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      subjectId: subjectId ?? this.subjectId,
      classroomId: classroomId ?? this.classroomId,
      schoolId: schoolId ?? this.schoolId,
      gradeType: gradeType ?? this.gradeType,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      date: date ?? this.date,
      recordedBy: recordedBy ?? this.recordedBy,
      notes: notes ?? this.notes,
      comments: comments ?? this.comments,
      metadata: metadata ?? this.metadata,
    );
  }

  double get percentage {
    if (maxScore == 0) return 0.0;
    return (score / maxScore) * 100;
  }

  String get performanceLevel {
    final percent = percentage;
    if (percent >= 90) return 'ممتاز';
    if (percent >= 80) return 'جيد جداً';
    if (percent >= 70) return 'جيد';
    if (percent >= 60) return 'مقبول';
    return 'ضعيف';
  }

  Color get performanceColor {
    final percent = percentage;
    if (percent >= 90) return const Color(0xFF7ED321); // أخضر فاتح
    if (percent >= 80) return const Color(0xFF50E3C2); // أخضر مائي
    if (percent >= 70) return const Color(0xFFF5A623); // برتقالي
    if (percent >= 60) return const Color(0xFFF8E71C); // أصفر فاتح
    return const Color(0xFFD0021B); // أحمر
  }

  String get gradeTypeText {
    switch (gradeType) {
      case 'daily':
        return 'درجة يومية';
      case 'weekly':
        return 'درجة أسبوعية';
      case 'monthly':
        return 'درجة شهرية';
      case 'midterm':
        return 'درجة منتصف الفصل';
      case 'final':
        return 'درجة نهائية';
      case 'project':
        return 'مشروع';
      case 'homework':
        return 'واجب منزلي';
      default:
        return gradeType;
    }
  }

  bool get isRecent {
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return date.isAfter(weekAgo);
  }

  String get formattedScore => '${score.toStringAsFixed(1)}/$maxScore';
  String get formattedPercentage => '${percentage.toStringAsFixed(1)}%';

  @override
  String toString() {
    return 'Grade(id: $id, studentId: $studentId, subjectId: $subjectId, score: $formattedScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Grade &&
        other.studentId == studentId &&
        other.subjectId == subjectId &&
        other.date == date &&
        other.gradeType == gradeType;
  }

  @override
  int get hashCode => Object.hash(studentId, subjectId, date, gradeType);
}
