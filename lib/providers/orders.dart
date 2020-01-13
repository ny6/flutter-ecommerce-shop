import 'package:flutter/foundation.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.datetime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders => [..._orders];

  void addOrder(List<CartItem> cartProducts, double total) {
    final datetime = DateTime.now();
    final order = OrderItem(
      id: datetime.toString(),
      amount: total,
      products: cartProducts,
      datetime: datetime,
    );
    _orders.insert(0, order);

    notifyListeners();
  }
}
