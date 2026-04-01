import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  const ProductRepositoryImpl({required ProductRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final ProductRemoteDataSource _remoteDataSource;

  @override
  Future<ProductPage> getProducts({
    required int page,
    required int limit,
    String? query,
  }) async {
    final result = await _remoteDataSource.getProducts(
      page: page,
      limit: limit,
      query: query,
    );

    return ProductPage(items: result.items, totalCount: result.totalCount);
  }
}
