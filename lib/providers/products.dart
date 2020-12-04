import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [];

  var _showFavoritesOnly = false;
  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return items.firstWhere((item) => item.id == id);
  }

  // void showFavorites() {
  //   _showFavoritesOnly = true;
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  // }

  Future<void> getProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="userId"&equalTo="$userId"' : '';
    var url =
        'https://shopapp-60226.firebaseio.com/product.json?auth=$authToken$filterString';
    try {
      final product = await http.get(url);
      final productItem = json.decode(product.body) as Map<String, dynamic>;
      if (productItem == null) {
        return;
      }
      url =
          'https://shopapp-60226.firebaseio.com/userFavorites/$userId.json?auth=$authToken';
      final favoritesResponse = await http.get(url);
      final favorites = json.decode(favoritesResponse.body);
      final List<Product> loadedProduct = [];
      productItem.forEach((itemId, item) {
        loadedProduct.add(Product(
          id: itemId,
          title: item['title'],
          description: item['description'],
          price: item['price'],
          imageUrl: item['imageUrl'],
          isFavorite: favorites == null ? false : favorites[itemId] ?? false,
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        'https://shopapp-60226.firebaseio.com/product.json?auth=$authToken';
    try {
      final products = await http.post(
        url,
        body: json.encode({
          'imageUrl': product.imageUrl,
          'price': product.price,
          'description': product.description,
          'title': product.title,
          'userId': userId,
        }),
      );

      final productDetails = Product(
        id: json.decode(products.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        description: product.description,
        title: product.title,
      );
      _items.add(productDetails);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> updateProduct(Product product, String id) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shopapp-60226.firebaseio.com/product/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'imageUrl': product.imageUrl,
            'price': product.price,
            'description': product.description,
            'title': product.title,
          }));

      _items[prodIndex] = product;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://shopapp-60226.firebaseio.com/product/$id.json?auth=$authToken';
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product. ');
    }
    existingProduct = null;
  }
}
