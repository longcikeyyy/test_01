part of 'product_list_bloc.dart';

sealed class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object?> get props => [];
}

class ProductListFetched extends ProductListEvent {
  const ProductListFetched();
}

class ProductListAllSelected extends ProductListEvent {
  const ProductListAllSelected();
}

class ProductListNewestSelected extends ProductListEvent {
  const ProductListNewestSelected();
}

class ProductListSearchChanged extends ProductListEvent {
  const ProductListSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ProductListInStockToggled extends ProductListEvent {
  const ProductListInStockToggled(this.enabled);

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}

class ProductListSortToggled extends ProductListEvent {
  const ProductListSortToggled();
}

class ProductListPageChanged extends ProductListEvent {
  const ProductListPageChanged(this.nextPage);

  final int nextPage;

  @override
  List<Object?> get props => [nextPage];
}

class ProductListDraftQtyChanged extends ProductListEvent {
  const ProductListDraftQtyChanged({
    required this.productId,
    required this.quantity,
  });

  final int productId;
  final int quantity;

  @override
  List<Object?> get props => [productId, quantity];
}

class ProductListAddedToCart extends ProductListEvent {
  const ProductListAddedToCart(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class ProductListCartUpdated extends ProductListEvent {
  const ProductListCartUpdated(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}

class ProductListCartRemoved extends ProductListEvent {
  const ProductListCartRemoved(this.productId);

  final int productId;

  @override
  List<Object?> get props => [productId];
}
