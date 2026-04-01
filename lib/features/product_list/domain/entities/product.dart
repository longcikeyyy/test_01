import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.description,
    required this.category,
    required this.stock,
  });

  final int id;
  final String name;
  final int price;
  final String image;
  final String description;
  final String category;
  final int stock;

  bool get inStock => stock > 0;

  @override
  List<Object?> get props => [id, name, price, image, description, category, stock];
}
