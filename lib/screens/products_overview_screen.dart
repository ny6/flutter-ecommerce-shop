import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class ProductsOverviewScreen extends StatelessWidget {
  static const routeName = '/';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('MyShop')),
      body: ProductsGrid(),
    );
  }
}
