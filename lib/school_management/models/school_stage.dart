class SchoolStage {
  final String id;
  final String schoolId;
  final String name;
  final String? description;
  final int order;
  final bool isActive;
  final DateTime createdAt;

  SchoolStage({
    required this.id,
    required this.schoolId,
    required this.name,
    this.description,
    required this.order,
    this.isActive = true,
    required this.createdAt,
  });

  // إنشاء مرحلة من JSON
  factory SchoolStage.fromJson(Map<String, dynamic> json) {
    return SchoolStage(
      id: json['id'] as String,
      schoolId: json['schoolId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      order: json['order'] as int,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // تحويل المرحلة إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'schoolId': schoolId,
      'name': name,
      'description': description,
      'order': order,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // نسخ المرحلة مع تعديلات
  SchoolStage copyWith({
    String? id,
    String? schoolId,
    String? name,
    String? description,
    int? order,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SchoolStage(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SchoolStage(id: $id, name: $name, schoolId: $schoolId, order: $order)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SchoolStage && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
