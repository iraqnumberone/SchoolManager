class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String fullName;
  final String studentId;
  final DateTime birthDate;
  final String gender;
  final String address;
  final String phone;
  final String? parentPhone;
  final String schoolId;
  final String stageId;
  final String classGroupId;
  final String status;
  final String? photo;
  final DateTime enrollmentDate;
  final Map<String, dynamic>? additionalInfo;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    required this.studentId,
    required this.birthDate,
    required this.gender,
    required this.address,
    required this.phone,
    this.parentPhone,
    required this.schoolId,
    required this.stageId,
    required this.classGroupId,
    required this.status,
    this.photo,
    required this.enrollmentDate,
    this.additionalInfo,
  });

  // إنشاء طالب من JSON
  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      fullName: json['fullName'] as String,
      studentId: json['studentId'] as String,
      birthDate: DateTime.parse(json['birthDate'] as String),
      gender: json['gender'] as String,
      address: json['address'] as String,
      phone: json['phone'] as String,
      parentPhone: json['parentPhone'] as String?,
      schoolId: json['schoolId'] as String,
      stageId: json['stageId'] as String,
      classGroupId: json['classGroupId'] as String,
      status: json['status'] as String,
      photo: json['photo'] as String?,
      enrollmentDate: DateTime.parse(json['enrollmentDate'] as String),
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>?,
    );
  }

  // تحويل الطالب إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'fullName': fullName,
      'studentId': studentId,
      'birthDate': birthDate.toIso8601String(),
      'gender': gender,
      'address': address,
      'phone': phone,
      'parentPhone': parentPhone,
      'schoolId': schoolId,
      'stageId': stageId,
      'classGroupId': classGroupId,
      'status': status,
      'photo': photo,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'additionalInfo': additionalInfo,
    };
  }

  // نسخ الطالب مع تعديلات
  Student copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? fullName,
    String? studentId,
    DateTime? birthDate,
    String? gender,
    String? address,
    String? phone,
    String? parentPhone,
    String? schoolId,
    String? stageId,
    String? classGroupId,
    String? status,
    String? photo,
    DateTime? enrollmentDate,
    Map<String, dynamic>? additionalInfo,
  }) {
    return Student(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      birthDate: birthDate ?? this.birthDate,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      parentPhone: parentPhone ?? this.parentPhone,
      schoolId: schoolId ?? this.schoolId,
      stageId: stageId ?? this.stageId,
      classGroupId: classGroupId ?? this.classGroupId,
      status: status ?? this.status,
      photo: photo ?? this.photo,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  // حساب العمر
  int get age {
    final now = DateTime.now();
    int age = now.year - birthDate.year;
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // الحصول على الأحرف الأولى من الاسم
  String get initials {
    return '${firstName[0]}${lastName[0]}'.toUpperCase();
  }

  // الحصول على معلومات الطالب بتنسيق جميل
  String get displayInfo {
    return '$fullName - $studentId';
  }

  // الحصول على معلومات الموقع الدراسي
  String get locationInfo {
    return 'المرحلة: $stageId - الشعبة: $classGroupId';
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
