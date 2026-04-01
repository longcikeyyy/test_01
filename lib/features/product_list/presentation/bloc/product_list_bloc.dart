import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_products_usecase.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  ProductListBloc({required GetProductsUseCase getProductsUseCase})
    : _getProductsUseCase = getProductsUseCase,
      super(const ProductListState()) {
    on<ProductListFetched>(_onFetched);
    on<ProductListAllSelected>(_onAllSelected);
    on<ProductListNewestSelected>(_onNewestSelected);
    on<ProductListSearchChanged>(_onSearchChanged);
    on<ProductListInStockToggled>(_onInStockToggled);
    on<ProductListSortToggled>(_onSortToggled);
    on<ProductListPageChanged>(_onPageChanged);
    on<ProductListDraftQtyChanged>(_onDraftQtyChanged);
    on<ProductListAddedToCart>(_onAddToCart);
    on<ProductListCartUpdated>(_onUpdateCartQty);
    on<ProductListCartRemoved>(_onRemoveFromCart);
  }

  final GetProductsUseCase _getProductsUseCase;

  Product? _findProductById(int productId) {
    for (final product in state.products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  Future<void> _onFetched(
    ProductListFetched event,
    Emitter<ProductListState> emit,
  ) async {
    emit(
      state.copyWith(
        status: ProductListStatus.loading,
        clearErrorMessage: true,
      ),
    );
    try {
      final result = await _getProductsUseCase(
        page: state.page,
        limit: state.limit,
        query: state.search,
      );
      emit(
        state.copyWith(
          status: ProductListStatus.success,
          products: result.items,
          totalCount: result.totalCount,
          clearErrorMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProductListStatus.failure,
          errorMessage: 'Không thể tải danh sách sản phẩm',
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    ProductListSearchChanged event,
    Emitter<ProductListState> emit,
  ) async {
    emit(state.copyWith(search: event.query, page: 1));
    add(const ProductListFetched());
  }

  void _onAllSelected(
    ProductListAllSelected event,
    Emitter<ProductListState> emit,
  ) {
    emit(state.copyWith(selectedTopTab: ProductTopTab.all));
    add(const ProductListFetched());
  }

  void _onNewestSelected(
    ProductListNewestSelected event,
    Emitter<ProductListState> emit,
  ) {
    emit(state.copyWith(selectedTopTab: ProductTopTab.newest));
    add(const ProductListFetched());
  }

  void _onInStockToggled(
    ProductListInStockToggled event,
    Emitter<ProductListState> emit,
  ) {
    emit(state.copyWith(inStockOnly: event.enabled));
  }

  void _onSortToggled(
    ProductListSortToggled event,
    Emitter<ProductListState> emit,
  ) {
    emit(
      state.copyWith(
        sortAsc: !state.sortAsc,
        selectedTopTab: ProductTopTab.price,
      ),
    );
  }

  Future<void> _onPageChanged(
    ProductListPageChanged event,
    Emitter<ProductListState> emit,
  ) async {
    if (event.nextPage < 1) return;
    emit(state.copyWith(page: event.nextPage));
    add(const ProductListFetched());
  }

  void _onDraftQtyChanged(
    ProductListDraftQtyChanged event,
    Emitter<ProductListState> emit,
  ) {
    final draft = Map<int, int>.from(state.draftQty);
    draft[event.productId] = event.quantity;
    emit(state.copyWith(draftQty: draft));
  }

  void _onAddToCart(
    ProductListAddedToCart event,
    Emitter<ProductListState> emit,
  ) {
    final product = _findProductById(event.productId);
    if (product == null || !product.inStock) return;

    final quantity = (state.draftQty[event.productId] ?? 1).clamp(
      1,
      product.stock,
    );
    final next = Map<int, int>.from(state.cart);
    next[event.productId] = quantity;
    emit(state.copyWith(cart: next));
  }

  void _onUpdateCartQty(
    ProductListCartUpdated event,
    Emitter<ProductListState> emit,
  ) {
    final product = _findProductById(event.productId);
    if (product == null || !product.inStock) return;

    final next = Map<int, int>.from(state.cart);
    final quantity =
        (state.draftQty[event.productId] ?? next[event.productId] ?? 1).clamp(
          1,
          product.stock,
        );
    next[event.productId] = quantity;
    emit(state.copyWith(cart: next));
  }

  void _onRemoveFromCart(
    ProductListCartRemoved event,
    Emitter<ProductListState> emit,
  ) {
    final next = Map<int, int>.from(state.cart);
    next.remove(event.productId);
    emit(state.copyWith(cart: next));
  }
}
