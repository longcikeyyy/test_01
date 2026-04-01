import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ProductRemoteDataSource {
  ProductRemoteDataSource({required http.Client client}) : _client = client;

  static const String _baseUrl =
      'https://my-json-server.typicode.com/honganh-vn/product-list-demo';

  final http.Client _client;

  Future<ProductRemoteResult> getProducts({
    required int page,
    required int limit,
    String? query,
  }) async {
    final params = <String, String>{
      '_page': '$page',
      '_limit': '$limit',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };

    final uri = Uri.parse('$_baseUrl/products').replace(queryParameters: params);
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw Exception('API error: ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid response format');
    }

    final items = decoded
        .whereType<Map<String, dynamic>>()
        .map(ProductModel.fromJson)
        .toList();

    final totalCount = int.tryParse(response.headers['x-total-count'] ?? '');
    return ProductRemoteResult(items: items, totalCount: totalCount);
  }
}

class ProductRemoteResult {
  const ProductRemoteResult({required this.items, required this.totalCount});

  final List<ProductModel> items;
  final int? totalCount;
}
