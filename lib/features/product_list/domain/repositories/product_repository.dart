import '../entities/product.dart';

abstract class ProductRepository {
  Future<ProductPage> getProducts({
    required int page,
    required int limit,
    String? query,
  });
}

class ProductPage {
  const ProductPage({required this.items, required this.totalCount});

  final List<Product> items;
  final int? totalCount;
}
