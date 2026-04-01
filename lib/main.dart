import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import 'core/theme/app_colors.dart';
import 'features/product_list/data/datasources/product_remote_data_source.dart';
import 'features/product_list/data/repositories/product_repository_impl.dart';
import 'features/product_list/domain/usecases/get_products_usecase.dart';
import 'features/product_list/presentation/bloc/product_list_bloc.dart';
import 'features/product_list/presentation/pages/product_list_page.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final dataSource = ProductRemoteDataSource(client: http.Client());
    final repository = ProductRepositoryImpl(remoteDataSource: dataSource);
    final getProductsUseCase = GetProductsUseCase(repository);

    return BlocProvider(
      create: (_) => ProductListBloc(getProductsUseCase: getProductsUseCase),
      child: MaterialApp(
        title: 'Product List',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryBlue),
          scaffoldBackgroundColor: AppColors.screenBackground,
        ),
        home: const ProductListPage(),
      ),
    );
  }
}
