class School {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String email;
  final String? logo;
  final String directorName;
  final DateTime createdAt;
  final bool isActive;

  // الحقول الجديدة المطلوبة
  final String educationLevel; // مرحلة الدراسة (ابتدائي، متوسط، ثانوي)
  final String section; // الشعبة (أ، ب، ج، إلخ)
  final int studentCount; // عدد الطلاب

  School({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.email,
    this.logo,
    required this.directorName,
    required this.createdAt,
    this.isActive = true,
    required this.educationLevel,
    required this.section,
    required this.studentCount,
  });

  // إنشاء مدرسة من JSON
  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      id: json['id'] as String,
      name: json['name'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      logo: json['logo'] as String?,
      directorName: json['directorName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool? ?? true,
      educationLevel: json['educationLevel'] as String,
      section: json['section'] as String,
      studentCount: json['studentCount'] as int,
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
      'logo': logo,
      'directorName': directorName,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
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
