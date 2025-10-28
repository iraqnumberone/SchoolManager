import 'package:flutter/material.dart';

class Teacher {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String employeeId;
  final String email;
  final String phone;
  final String nationalId;
  final String qualification; // البكالوريوس، الماجستير، الدكتوراه
  final String specialization; // التخصص الدراسي
  final List<String> subjects; // المواد التي يدرسها
  final String schoolId;
  final String status; // active, inactive, on_leave
  final DateTime hireDate;
  final String? profileImage;
  final Map<String, dynamic> contactInfo;
  final Map<String, dynamic> emergencyContact;
  final Map<String, dynamic> settings;

  Teacher({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.qualification,
    required this.specialization,
    required this.subjects,
    required this.schoolId,
    required this.status,
    required this.hireDate,
    this.profileImage,
    this.contactInfo = const {},
    this.emergencyContact = const {},
    this.settings = const {},
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      employeeId: json['employeeId'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      nationalId: json['nationalId'] as String,
      qualification: json['qualification'] as String,
      specialization: json['specialization'] as String,
      subjects: List<String>.from(json['subjects'] as List),
      schoolId: json['schoolId'] as String,
      status: json['status'] as String,
      hireDate: DateTime.parse(json['hireDate'] as String),
      profileImage: json['profileImage'] as String?,
      contactInfo: json['contactInfo'] as Map<String, dynamic>? ?? {},
      emergencyContact: json['emergencyContact'] as Map<String, dynamic>? ?? {},
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'employeeId': employeeId,
      'email': email,
      'phone': phone,
      'nationalId': nationalId,
      'qualification': qualification,
      'specialization': specialization,
      'subjects': subjects,
      'schoolId': schoolId,
      'status': status,
      'hireDate': hireDate.toIso8601String(),
      'profileImage': profileImage,
      'contactInfo': contactInfo,
      'emergencyContact': emergencyContact,
      'settings': settings,
    };
  }

  Teacher copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? employeeId,
    String? email,
    String? phone,
    String? nationalId,
    String? qualification,
    String? specialization,
    List<String>? subjects,
    String? schoolId,
    String? status,
    DateTime? hireDate,
    String? profileImage,
    Map<String, dynamic>? contactInfo,
    Map<String, dynamic>? emergencyContact,
    Map<String, dynamic>? settings,
  }) {
    return Teacher(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      subjects: subjects ?? this.subjects,
      schoolId: schoolId ?? this.schoolId,
      status: status ?? this.status,
      hireDate: hireDate ?? this.hireDate,
      profileImage: profileImage ?? this.profileImage,
      contactInfo: contactInfo ?? this.contactInfo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      settings: settings ?? this.settings,
    );
  }

  String get qualificationText {
    switch (qualification) {
      case 'bachelor':
        return 'بكالوريوس';
      case 'master':
        return 'ماجستير';
      case 'phd':
        return 'دكتوراه';
      default:
        return qualification;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'inactive':
        return Colors.red;
      case 'on_leave':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'inactive':
        return 'غير نشط';
      case 'on_leave':
        return 'في إجازة';
      default:
        return 'غير محدد';
    }
  }

  String get subjectsText => subjects.join(', ');

  int get yearsOfExperience {
    final now = DateTime.now();
    return now.year - hireDate.year;
  }

  String get initials {
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  @override
  String toString() {
    return 'Teacher(id: $id, name: $fullName, subjects: $subjectsText)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Teacher && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
