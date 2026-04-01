import '../repositories/product_repository.dart';

class GetProductsUseCase {
  const GetProductsUseCase(this.repository);

  final ProductRepository repository;

  Future<ProductPage> call({
    required int page,
    required int limit,
    String? query,
  }) {
    return repository.getProducts(page: page, limit: limit, query: query);
  }
}
