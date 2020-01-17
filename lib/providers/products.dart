import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import './product.dart';

class Products with ChangeNotifier {
  String _authToken;

  set authToken(String value) {
    _authToken = value;
  }

  List<Product> _items = [];

  List<Product> get items => [..._items];

  List<Product> get favoriteItems => _items.where((p) => p.isFavorite).toList();

  Product findById(String id) => _items.firstWhere((prod) => prod.id == id);

  Future<void> fetchAndSetProducts() async {
    final _url =
        'https://ecommerce-yk.firebaseio.com/products.json?auth=$_authToken';
    final res = await http.get(_url);
    final body = json.decode(res.body) as Map<String, dynamic>;

    final List<Product> products = [];

    body.forEach(
      (key, value) => products.add(Product(
        id: key,
        title: value['title'],
        description: value['description'],
        price: value['price'],
        imageUrl: value['imageUrl'],
        isFavorite: value['isFavorite'] ?? false,
      )),
    );
    _items = products;
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final body = json.encode({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
    });

    final _url =
        'https://ecommerce-yk.firebaseio.com/products.json?auth=$_authToken';

    final res = await http.post(_url, body: body);

    final newProduct = Product(
      id: json.decode(res.body)['name'],
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
    );

    _items.add(newProduct);

    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    final url =
        'https://ecommerce-yk.firebaseio.com/products/${product.id}.json';
    final body = json.encode({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'imageUrl': product.imageUrl,
    });

    await http.patch(url, body: body);

    final index = _items.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://ecommerce-yk.firebaseio.com/products/$id.json';
    await http.delete(url);

    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }
}
