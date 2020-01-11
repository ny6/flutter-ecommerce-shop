import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/providers.dart';
import './product_item.dart';

class ProductsGrid extends StatelessWidget {
  ProductsGrid(this._showOnlyFavorites);

  final bool _showOnlyFavorites;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    final products =
        _showOnlyFavorites ? productsData.favoriteItems : productsData.items;

    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: products[i],
        child: ProductItem(),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
