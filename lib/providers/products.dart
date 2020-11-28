import 'package:flutter/material.dart';

import './product.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
        id: 'p2',
        title: 'Red Face Cap',
        description: 'A nice pair of trousers.',
        price: 59.99,
        imageUrl:
            'https://www-konga-com-res.cloudinary.com/w_auto,f_auto,fl_lossy,dpr_auto,q_auto/media/catalog/product/T/D/142592_1566811700.jpg'),
    Product(
        id: 'p3',
        title: 'Black Shoe',
        description: 'A nice pair of trousers.',
        price: 59.99,
        imageUrl:
            'https://ng.jumia.is/unsafe/fit-in/680x680/filters:fill(white)/product/61/152006/1.jpg?7348'),
    Product(
        id: 'p4',
        title: 'Trousers',
        description: 'A nice pair of trousers.',
        price: 59.99,
        imageUrl:
            'https://images.journeys.com/images/products/1_602366_ZM_ALT1.JPG')
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

  void aadProduct(Product product) {
    final productDetails = Product(
      id: DateTime.now().toString(),
      imageUrl: product.imageUrl,
      price: product.price,
      description: product.description,
      title: product.title,
    );
    _items.add(productDetails);
    notifyListeners();
  }

  void updateProduct(Product updatedProduct, String id) {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      _items[productIndex] = updatedProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }
}
