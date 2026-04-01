import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.image,
    required super.description,
    required super.category,
    required super.stock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final inStockFlag = json['inStock'];
    final hasLegacyStock = json['stock'] != null;
    final derivedStock = hasLegacyStock
        ? (json['stock'] as num?)?.toInt() ?? 0
        : (inStockFlag == true ? 99 : 0);

    return ProductModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? (json['title'] as String?) ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      image: json['image'] as String? ?? '',
      description:
          (json['description'] as String?) ?? (json['body'] as String?) ?? '',
      category: json['category'] as String? ?? '',
      stock: derivedStock,
    );
  }
}
