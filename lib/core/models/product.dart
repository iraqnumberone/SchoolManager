class ProductModel {
  final int? id;
  final String title;
  final double price;
  final int stock;
  final int? createdAt;

  ProductModel({
    this.id,
    required this.title,
    required this.price,
    this.stock = 0,
    this.createdAt,
  });

  ProductModel copyWith({
    int? id,
    String? title,
    double? price,
    int? stock,
    int? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'price': price,
    'stock': stock,
    'created_at': createdAt,
  };

  factory ProductModel.fromMap(Map<String, Object?> map) => ProductModel(
    id: map['id'] as int?,
    title: (map['title'] ?? '') as String,
    price: (map['price'] as num?)?.toDouble() ?? 0.0,
    stock: (map['stock'] as num?)?.toInt() ?? 0,
    createdAt: map['created_at'] as int?,
  );
}
