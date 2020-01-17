import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './screens/screens.dart';
import './providers/providers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Cart()),
        ChangeNotifierProvider.value(value: Orders()),
        ChangeNotifierProxyProvider<Auth, Products>(
          create: (_) => Products(),
          update: (_, auth, products) => products..authToken = auth.token,
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.purple,
            accentColor: Colors.deepOrange,
            fontFamily: 'Lato',
          ),
          home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
          routes: {
            AuthScreen.routeName: (_) => AuthScreen(),
            ProductsOverviewScreen.routeName: (_) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (_) => ProductDetailScreen(),
            CartScreen.routeName: (_) => CartScreen(),
            OrdersScreen.routeName: (_) => OrdersScreen(),
            UserProductsScreen.routeName: (_) => UserProductsScreen(),
            EditProductScreen.routeName: (_) => EditProductScreen(),
          },
        ),
      ),
    );
  }
}
