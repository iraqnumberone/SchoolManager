class UserModel {
  final int? id;
  final String name;
  final String? email;
  final int? createdAt; // epoch millis

  UserModel({this.id, required this.name, this.email, this.createdAt});

  UserModel copyWith({int? id, String? name, String? email, int? createdAt}) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'created_at': createdAt,
  };

  factory UserModel.fromMap(Map<String, Object?> map) => UserModel(
    id: map['id'] as int?,
    name: (map['name'] ?? '') as String,
    email: map['email'] as String?,
    createdAt: map['created_at'] as int?,
  );
}
