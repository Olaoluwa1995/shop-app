import 'package:flutter/foundation.dart';

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  // Map product id and cartitem
  Map<String, CartItem> _items;

  Map<String, CartItem> get items {
    return {..._items};
  }

  // add item to cart
  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      // item already exist in the cart
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          price: existingCartItem.price,
          quantity: existingCartItem.quantity + 1,
        ),
      );
    } else {
      _items.putIfAbsent(
        productId,
        //creating new cart item
        () => new CartItem(
          id: DateTime.now().toString(),
          title: title,
          price: price,
          quantity: 1,
        ),
      );
    }
  }
}
