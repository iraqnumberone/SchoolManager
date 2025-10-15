import 'package:flutter/material.dart';

class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String studentId;
  final String nationalId;
  final DateTime birthDate;
  final String gender;
  final String nationality;
  final String address;
  final String phone;
  final String? parentPhone;
  final String? parentEmail;
  final String schoolId;
  final String classroomId;
  final String status; // active, inactive, graduated, transferred
  final String? profileImage;
  final String bloodType;
  final String? medicalConditions;
  final String? allergies;
  final Map<String, dynamic> parentInfo;
  final Map<String, dynamic> emergencyContact;
  final Map<String, dynamic> academicRecord;
  final Map<String, dynamic> settings;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.studentId,
    required this.nationalId,
    required this.birthDate,
    required this.gender,
    required this.nationality,
    required this.address,
    required this.phone,
    this.parentPhone,
    this.parentEmail,
    required this.schoolId,
    required this.classroomId,
    required this.status,
    this.profileImage,
    this.bloodType = 'O+',
    this.medicalConditions,
    this.allergies,
    this.parentInfo = const {},
    this.emergencyContact = const {},
    this.academicRecord = const {},
    this.settings = const {},
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      studentId: json['studentId'] as String,
      nationalId: json['nationalId'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      nationality: json['nationality'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      parentPhone: json['parentPhone'] as String?,
      parentEmail: json['parentEmail'] as String?,
      schoolId: json['schoolId'] as String,
      classroomId: json['classroomId'] as String,
      status: json['status'] as String,
      profileImage: json['profileImage'] as String?,
      bloodType: json['bloodType'] as String? ?? 'O+',
      medicalConditions: json['medicalConditions'] as String?,
      allergies: json['allergies'] as String?,
      parentInfo: json['parentInfo'] as Map<String, dynamic>? ?? {},
      emergencyContact: json['emergencyContact'] as Map<String, dynamic>? ?? {},
      academicRecord: json['academicRecord'] as Map<String, dynamic>? ?? {},
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'studentId': studentId,
      'nationalId': nationalId,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'nationality': nationality,
      'address': address,
      'phone': phone,
      'parentPhone': parentPhone,
      'parentEmail': parentEmail,
      'schoolId': schoolId,
      'classroomId': classroomId,
      'status': status,
      'profileImage': profileImage,
      'bloodType': bloodType,
      'medicalConditions': medicalConditions,
      'allergies': allergies,
      'parentInfo': parentInfo,
      'emergencyContact': emergencyContact,
      'academicRecord': academicRecord,
      'settings': settings,
    };
  }

  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? studentId,
    String? nationalId,
    DateTime? birthDate,
    String? gender,
    String? nationality,
    String? address,
    String? phone,
    String? parentPhone,
    String? parentEmail,
    String? schoolId,
    String? classroomId,
    String? status,
    String? profileImage,
    String? bloodType,
    String? medicalConditions,
    String? allergies,
    Map<String, dynamic>? parentInfo,
    Map<String, dynamic>? emergencyContact,
    Map<String, dynamic>? academicRecord,
    Map<String, dynamic>? settings,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      nationalId: nationalId ?? this.nationalId,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      nationality: nationality ?? this.nationality,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      parentPhone: parentPhone ?? this.parentPhone,
      parentEmail: parentEmail ?? this.parentEmail,
      schoolId: schoolId ?? this.schoolId,
      classroomId: classroomId ?? this.classroomId,
      status: status ?? this.status,
      profileImage: profileImage ?? this.profileImage,
      bloodType: bloodType ?? this.bloodType,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      allergies: allergies ?? this.allergies,
      parentInfo: parentInfo ?? this.parentInfo,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      academicRecord: academicRecord ?? this.academicRecord,
      settings: settings ?? this.settings,
    );
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  String get initials {
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  String get genderText {
    switch (gender) {
      case 'male': return 'ذكر';
      case 'female': return 'أنثى';
      default: return 'غير محدد';
    }
  }

  Color get statusColor {
    switch (status) {
      case 'active': return Colors.green;
      case 'inactive': return Colors.red;
      case 'graduated': return Colors.blue;
      case 'transferred': return Colors.orange;
      default: return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'active': return 'نشط';
      case 'inactive': return 'غير نشط';
      case 'graduated': return 'متخرج';
      case 'transferred': return 'منقول';
      default: return 'غير محدد';
    }
  }

  String get bloodTypeText {
    switch (bloodType) {
      case 'A+': return 'A+';
      case 'A-': return 'A-';
      case 'B+': return 'B+';
      case 'B-': return 'B-';
      case 'AB+': return 'AB+';
      case 'AB-': return 'AB-';
      case 'O+': return 'O+';
      case 'O-': return 'O-';
      default: return bloodType;
    }
  }

  @override
  String toString() {
    return 'Student(id: $id, name: $fullName, studentId: $studentId, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Student && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
