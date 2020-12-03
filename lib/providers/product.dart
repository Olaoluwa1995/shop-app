import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

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
    this.isFavorite = false,
    @required this.imageUrl,
  });

  Future<void> toggleFavoriteStatus(
      String id, String authToken, String userId) async {
    final url =
        'https://shopapp-60226.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    isFavorite = !isFavorite;
    notifyListeners();

    final response = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Could not delete product');
    }
  }
}
