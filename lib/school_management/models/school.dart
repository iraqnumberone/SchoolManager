class School {
  final String id;
  String name;
  String address;
  String phone;
  String email;
  final String? logo;
  String directorName;
  final DateTime createdAt;
  DateTime updatedAt;
  bool isActive;
  String educationLevel; // مرحلة الدراسة (ابتدائي، متوسط، ثانوي)
  String section; // الشعبة (أ، ب، ج، إلخ)
  int studentCount; // عدد الطلاب

  School({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.logo,
    this.directorName = 'غير محدد',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.isActive = true,
    this.educationLevel = 'غير محدد',
    this.section = 'أ',
    this.studentCount = 0,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // إنشاء مدرسة من JSON
  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      logo: json['logo']?.toString(),
      directorName: json['directorName']?.toString() ?? 'غير محدد',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      isActive: json['isActive'] == 1 || json['isActive'] == true,
      educationLevel: json['educationLevel']?.toString() ?? 'غير محدد',
      section: json['section']?.toString() ?? 'أ',
      studentCount: (json['studentCount'] is int)
          ? json['studentCount'] as int
          : int.tryParse(json['studentCount']?.toString() ?? '0') ?? 0,
    );
  }

  // تحويل المدرسة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      if (logo != null) 'logo': logo,
      'directorName': directorName,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive ? 1 : 0,
      'educationLevel': educationLevel,
      'section': section,
      'studentCount': studentCount,
    };
  }

  // نسخ المدرسة مع تعديلات
  School copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? logo,
    String? directorName,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? educationLevel,
    String? section,
    int? studentCount,
  }) {
    return School(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logo: logo ?? this.logo,
      directorName: directorName ?? this.directorName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      educationLevel: educationLevel ?? this.educationLevel,
      section: section ?? this.section,
      studentCount: studentCount ?? this.studentCount,
    );
  }

  @override
  String toString() {
    return 'School(id: $id, name: $name, address: $address, phone: $phone, educationLevel: $educationLevel, section: $section, students: $studentCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is School && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
