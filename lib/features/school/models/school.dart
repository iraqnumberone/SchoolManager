import 'package:flutter/material.dart';

class School {
  final String id;
  final String name;
  final String nameEn;
  final String logo;
  final String address;
  final String phone;
  final String email;
  final String website;
  final String principalName;
  final String schoolType; // public, private, international
  final int totalStudents;
  final int totalTeachers;
  final int totalClasses;
  final DateTime establishedDate;
  final String description;
  final Map<String, dynamic> settings;

  School({
    required this.id,
    required this.name,
    required this.nameEn,
    this.logo = '',
    required this.address,
    required this.phone,
    required this.email,
    this.website = '',
    required this.principalName,
    required this.schoolType,
    this.totalStudents = 0,
    this.totalTeachers = 0,
    this.totalClasses = 0,
    required this.establishedDate,
    this.description = '',
    this.settings = const {},
  });

  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      name: json['name'] as String,
      nameEn: json['nameEn'] as String,
      logo: json['logo'] as String? ?? '',
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      website: json['website'] as String? ?? '',
      principalName: json['principalName'] as String,
      schoolType: json['schoolType'] as String,
      totalStudents: json['totalStudents'] as int? ?? 0,
      totalTeachers: json['totalTeachers'] as int? ?? 0,
      totalClasses: json['totalClasses'] as int? ?? 0,
      establishedDate: DateTime.parse(json['establishedDate'] as String),
      description: json['description'] as String? ?? '',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameEn': nameEn,
      'logo': logo,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'principalName': principalName,
      'schoolType': schoolType,
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalClasses': totalClasses,
      'establishedDate': establishedDate.toIso8601String(),
      'description': description,
      'settings': settings,
    };
  }

  School copyWith({
    String? id,
    String? name,
    String? nameEn,
    String? logo,
    String? address,
    String? phone,
    String? email,
    String? website,
    String? principalName,
    String? schoolType,
    int? totalStudents,
    int? totalTeachers,
    int? totalClasses,
    DateTime? establishedDate,
    String? description,
    Map<String, dynamic>? settings,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      logo: logo ?? this.logo,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      principalName: principalName ?? this.principalName,
      schoolType: schoolType ?? this.schoolType,
      totalStudents: totalStudents ?? this.totalStudents,
      totalTeachers: totalTeachers ?? this.totalTeachers,
      totalClasses: totalClasses ?? this.totalClasses,
      establishedDate: establishedDate ?? this.establishedDate,
      description: description ?? this.description,
      settings: settings ?? this.settings,
    );
  }

  String get displayName => name;
  String get typeText {
    switch (schoolType) {
      case 'public':
        return 'حكومية';
      case 'private':
        return 'خاصة';
      case 'international':
        return 'دولية';
      default:
        return 'غير محدد';
    }
  }

  Color get typeColor {
    switch (schoolType) {
      case 'public':
        return Colors.blue;
      case 'private':
        return Colors.green;
      case 'international':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  String toString() {
    return 'School(id: $id, name: $name, type: $schoolType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
