import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //     id: 'p2',
    //     title: 'Red Face Cap',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/T/D/142592_1566811700.jpg'),
    // Product(
    //     id: 'p3',
    //     title: 'Black Shoe',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://ng.jumia.is/unsafe/fit-in/680x680/filters:fill(white)/product/61/152006/1.jpg?7348'),
    // Product(
    //     id: 'p4',
    //     title: 'Trousers',
    //     description: 'A nice pair of trousers.',
    //     price: 59.99,
    //     imageUrl:
    //         'https://images.journeys.com/images/products/1_602366_ZM_ALT1.JPG')
  ];

  var _showFavoritesOnly = false;

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

  Future<void> getProduct() async {
    const url = 'https://shopapp-60226.firebaseio.com/product.json';
    try {
      final product = await http.get(url);
      final productItem = json.decode(product.body) as Map<String, dynamic>;
      if (productItem == null) {
        return;
      }
      final List<Product> loadedProduct = [];
      productItem.forEach((itemId, item) {
        loadedProduct.add(Product(
          id: itemId,
          title: item['title'],
          description: item['description'],
          price: item['price'],
          imageUrl: item['imageUrl'],
          isFavorite: item['isFavorite'],
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
    const url = 'https://shopapp-60226.firebaseio.com/product.json';
    try {
      final products = await http.post(
        url,
        body: json.encode({
          'imageUrl': product.imageUrl,
          'price': product.price,
          'description': product.description,
          'title': product.title,
          'isFavorite': product.isFavorite
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
      final url = 'https://shopapp-60226.firebaseio.com/product/$id.json';
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
    final url = 'https://shopapp-60226.firebaseio.com/product/$id.json';
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
