class SchoolStage {
  final String id;
  final String schoolId;
  final String name;
  final String? description;
  final int order;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  SchoolStage({
    required this.id,
    required this.schoolId,
    required this.name,
    this.description,
    required this.order,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // إنشاء مرحلة من JSON
  factory SchoolStage.fromJson(Map<String, dynamic> json) {
    return SchoolStage(
      id: json['id'].toString(),
      schoolId: json['schoolId'].toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      order: json['order'] is int
          ? json['order']
          : int.tryParse(json['order']?.toString() ?? '0') ?? 0,
      isActive:
          json['isActive'] == true ||
          (json['isActive'] is int && json['isActive'] == 1),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
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
      'updatedAt': updatedAt.toIso8601String(),
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
    DateTime? updatedAt,
  }) {
    return SchoolStage(
      id: id ?? this.id,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
