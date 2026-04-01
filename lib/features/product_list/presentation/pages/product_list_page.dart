import 'dart:async';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../domain/entities/product.dart';
import '../bloc/product_list_bloc.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  State<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  late final TextEditingController _searchController;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    context.read<ProductListBloc>().add(const ProductListFetched());
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      context.read<ProductListBloc>().add(ProductListSearchChanged(value));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.purple,
      body: SafeArea(
        child: Column(
          children: [
            _Header(
              searchController: _searchController,
              onSearchChanged: _onSearchChanged,
            ),
            _Filters(searchController: _searchController),
            const SizedBox(height: 12),
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                child: Container(
                  width: double.infinity,
                  color: AppColors.contentBackground,
                  child: const _ProductBody(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.searchController,
    required this.onSearchChanged,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.white,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                textInputAction: TextInputAction.search,
                onChanged: onSearchChanged,
                onSubmitted: (value) {
                  context.read<ProductListBloc>().add(
                    ProductListSearchChanged(value),
                  );
                },
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm trong {category}',
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.search_rounded, size: 20),
                  suffixIcon: IconButton(
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                      context.read<ProductListBloc>().add(
                        const ProductListSearchChanged(''),
                      );
                    },
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          BlocBuilder<ProductListBloc, ProductListState>(
            buildWhen: (previous, current) =>
                previous.cartCount != current.cartCount,
            builder: (context, state) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(
                    Icons.shopping_cart_outlined,
                    size: 24,
                    color: AppColors.white,
                  ),
                  Positioned(
                    right: -7,
                    top: -6,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${state.cartCount}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.searchController});

  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: BlocBuilder<ProductListBloc, ProductListState>(
        builder: (context, state) {
          return Row(
            children: [
              TextButton(
                onPressed: () {
                  context.read<ProductListBloc>().add(
                    const ProductListAllSelected(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: state.selectedTopTab == ProductTopTab.all
                      ? AppColors.white
                      : AppColors.tabInactive,
                  overlayColor: AppColors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 28),
                ),
                child: const Text(
                  'Tất cả',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 24 / 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: () {
                  context.read<ProductListBloc>().add(
                    const ProductListNewestSelected(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: state.selectedTopTab == ProductTopTab.newest
                      ? AppColors.white
                      : AppColors.tabInactive,
                  overlayColor: AppColors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 28),
                ),
                child: const Text('Mới nhất'),
              ),
              TextButton(
                onPressed: () {
                  context.read<ProductListBloc>().add(
                    const ProductListSortToggled(),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: state.selectedTopTab == ProductTopTab.price
                      ? AppColors.white
                      : AppColors.tabInactive,
                  overlayColor: AppColors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 0,
                  ),
                  minimumSize: const Size(0, 28),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Giá'),
                    const SizedBox(width: 4),
                    Icon(
                      state.sortAsc
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Còn hàng',
                style: TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              Switch(
                value: state.inStockOnly,
                onChanged: (value) {
                  context.read<ProductListBloc>().add(
                    ProductListInStockToggled(value),
                  );
                },
                activeTrackColor: AppColors.white,
                inactiveTrackColor: AppColors.switchInactiveTrack,
                inactiveThumbColor: AppColors.white,
                activeThumbColor: AppColors.primaryBlue,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProductBody extends StatelessWidget {
  const _ProductBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      builder: (context, state) {
        if (state.status == ProductListStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.status == ProductListStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.errorMessage ?? 'Đã có lỗi xảy ra',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductListBloc>().add(
                        const ProductListFetched(),
                      );
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        final items = state.visibleProducts;
        if (items.isEmpty) {
          return const Center(
            child: Text(
              'Không tìm thấy sản phẩm phù hợp',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<ProductListBloc>().add(
                    const ProductListFetched(),
                  );
                },
                child: ListView.separated(
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                  itemBuilder: (context, index) {
                    final product = items[index];
                    return _ProductCard(product: product);
                  },
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemCount: items.length,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: state.hasPreviousPage
                        ? () {
                            context.read<ProductListBloc>().add(
                              ProductListPageChanged(state.page - 1),
                            );
                          }
                        : null,
                    child: const Text('Trang trước'),
                  ),
                  const Spacer(),
                  Text(
                    'Trang ${state.page}',
                    style: const TextStyle(
                      color: AppColors.pageIndicator,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: state.hasNextPage
                        ? () {
                            context.read<ProductListBloc>().add(
                              ProductListPageChanged(state.page + 1),
                            );
                          }
                        : null,
                    child: const Text('Trang sau'),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductListBloc, ProductListState>(
      buildWhen: (previous, current) =>
          previous.cart != current.cart ||
          previous.draftQty != current.draftQty,
      builder: (context, state) {
        final inStock = product.inStock;
        final quantityInCart = state.cart[product.id] ?? 0;
        final hasInCart = quantityInCart > 0;
        final draftQty = state.draftQty[product.id] ?? 1;
        final oldPrice = (product.price * 1.5).round();

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    inStock ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: inStock ? AppColors.successGreen : AppColors.red,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    inStock ? 'Sẵn kho' : 'Hết hàng',
                    style: TextStyle(
                      color: inStock ? AppColors.successGreen : AppColors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const DottedLine(
                direction: Axis.horizontal,
                lineLength: double.infinity,
                lineThickness: 1,
                dashLength: 8,
                dashColor: AppColors.cardDivider,
                dashGapLength: 4,
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.productTitle,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product.description.isEmpty
                              ? 'Không có mô tả sản phẩm'
                              : product.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.productDescription,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: product.image.isEmpty
                          ? const ColoredBox(
                              color: AppColors.imagePlaceholderBackground,
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                color: AppColors.imagePlaceholderIcon,
                              ),
                            )
                          : Image.network(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const ColoredBox(
                                color: AppColors.imagePlaceholderBackground,
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  color: AppColors.imagePlaceholderIcon,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (hasInCart)
                          Text(
                            CurrencyFormatter.formatVnd(oldPrice),
                            style: const TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w400,
                              color: AppColors.oldPrice,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        Text(
                          CurrencyFormatter.formatVnd(product.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 28 / 29,
                            fontWeight: FontWeight.w600,
                            color: AppColors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (!inStock)
                    SizedBox(
                      width: 120,
                      height: 40,
                      child: TextButton(
                        onPressed: null,
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.disabledAddToCart,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(120, 40),
                        ),
                        child: const Text(
                          'Thêm vào giỏ',
                          style: TextStyle(color: AppColors.white),
                        ),
                      ),
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 15,
                          ),
                          width: 54,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.quantityBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.quantityBorder),
                          ),
                          child: TextFormField(
                            initialValue:
                                '${hasInCart ? quantityInCart : draftQty}',
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(
                              color: AppColors.quantityText,
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                            ),
                            onChanged: (value) {
                              final parsed = int.tryParse(value);
                              final qty = (parsed ?? 1).clamp(1, product.stock);
                              context.read<ProductListBloc>().add(
                                ProductListDraftQtyChanged(
                                  productId: product.id,
                                  quantity: qty,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasInCart)
                          SizedBox(
                            width: 76,
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                context.read<ProductListBloc>().add(
                                  ProductListCartUpdated(product.id),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.editButtonBackground,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(76, 40),
                              ),
                              child: const Text(
                                'Sửa',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: 120,
                            height: 40,
                            child: TextButton(
                              onPressed: () {
                                context.read<ProductListBloc>().add(
                                  ProductListAddedToCart(product.id),
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(120, 40),
                              ),
                              child: const Text(
                                'Thêm vào giỏ',
                                style: TextStyle(color: AppColors.white),
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        if (hasInCart)
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: OutlinedButton(
                              onPressed: () {
                                context.read<ProductListBloc>().add(
                                  ProductListCartRemoved(product.id),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                side: const BorderSide(
                                  color: AppColors.error50,
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.zero,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: AppColors.error50,
                              ),
                            ),
                          )
                        else
                          const SizedBox.shrink(),
                      ],
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
