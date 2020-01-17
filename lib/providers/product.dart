import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus() async {
    final oldStatus = isFavorite;
    // API won't work due to missing auth token
    final url = 'https://ecommerce-yk.firebaseio.com/products/$id.json';

    isFavorite = !isFavorite;
    notifyListeners();

    final body = json.encode({'isFavorite': isFavorite});

    final res = await http.patch(url, body: body);

    if (res.statusCode >= 400) {
      isFavorite = oldStatus;
      notifyListeners();
      throw HttpException('Something went wrong!');
    }
  }
}
