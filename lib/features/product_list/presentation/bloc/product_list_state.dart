part of 'product_list_bloc.dart';

enum ProductListStatus { initial, loading, success, failure }

enum ProductTopTab { all, newest, price }

class ProductListState extends Equatable {
  const ProductListState({
    this.status = ProductListStatus.initial,
    this.products = const <Product>[],
    this.errorMessage,
    this.page = 1,
    this.limit = 5,
    this.totalCount,
    this.search = '',
    this.inStockOnly = false,
    this.sortAsc = false,
    this.selectedTopTab = ProductTopTab.all,
    this.cart = const <int, int>{},
    this.draftQty = const <int, int>{},
  });

  final ProductListStatus status;
  final List<Product> products;
  final String? errorMessage;
  final int page;
  final int limit;
  final int? totalCount;
  final String search;
  final bool inStockOnly;
  final bool sortAsc;
  final ProductTopTab selectedTopTab;
  final Map<int, int> cart;
  final Map<int, int> draftQty;

  List<Product> get visibleProducts {
    var data = products;
    if (inStockOnly) {
      data = data.where((p) => p.inStock).toList();
    }

    final sorted = List<Product>.from(data)
      ..sort(
        (a, b) =>
            sortAsc ? a.price.compareTo(b.price) : b.price.compareTo(a.price),
      );
    return sorted;
  }

  bool get hasPreviousPage => page > 1;

  bool get hasNextPage {
    if (totalCount == null) {
      return products.length == limit;
    }
    return page * limit < totalCount!;
  }

  int get cartCount => cart.values.fold<int>(0, (sum, e) => sum + e);

  ProductListState copyWith({
    ProductListStatus? status,
    List<Product>? products,
    String? errorMessage,
    bool clearErrorMessage = false,
    int? page,
    int? limit,
    int? totalCount,
    bool clearTotalCount = false,
    String? search,
    bool? inStockOnly,
    bool? sortAsc,
    ProductTopTab? selectedTopTab,
    Map<int, int>? cart,
    Map<int, int>? draftQty,
  }) {
    return ProductListState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
      page: page ?? this.page,
      limit: limit ?? this.limit,
      totalCount: clearTotalCount ? null : (totalCount ?? this.totalCount),
      search: search ?? this.search,
      inStockOnly: inStockOnly ?? this.inStockOnly,
      sortAsc: sortAsc ?? this.sortAsc,
      selectedTopTab: selectedTopTab ?? this.selectedTopTab,
      cart: cart ?? this.cart,
      draftQty: draftQty ?? this.draftQty,
    );
  }

  @override
  List<Object?> get props => [
    status,
    products,
    errorMessage,
    page,
    limit,
    totalCount,
    search,
    inStockOnly,
    sortAsc,
    selectedTopTab,
    cart,
    draftQty,
  ];
}
