import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  bool paid;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
    @required this.paid,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> getOrders() async {
    final url =
        'https://shopapp-60226.firebaseio.com/order/$userId.json?auth=$authToken';
    try {
      final orders = await http.get(url);
      // print(json.decode(orders.body));
      final fetchedOrders = json.decode(orders.body) as Map<String, dynamic>;
      if (fetchedOrders == null) {
        _orders = [];
        return;
      }
      final List<OrderItem> loadedOrders = [];
      fetchedOrders.forEach((orderId, order) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: order['amount'],
            products: (order['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['amount'],
                    imageUrl: item['image'],
                  ),
                )
                .toList(),
            dateTime: DateTime.parse(order['dateTime']),
            paid: order['paid'],
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      print(err);
      HttpException('Internal server error');
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    // print('i got here');
    final url =
        'https://shopapp-60226.firebaseio.com/order/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    try {
      final order = await http.post(url,
          body: json.encode({
            'amount': total,
            'products': cartProducts
                .map((cp) => {
                      'id': cp.id,
                      'title': cp.title,
                      'amount': cp.price,
                      'quantity': cp.quantity,
                      'imageUrl': cp.imageUrl
                    })
                .toList(),
            'dateTime': timestamp.toIso8601String(),
            'paid': false,
          }));
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(order.body)['name'],
          amount: total,
          products: cartProducts,
          dateTime: timestamp,
          paid: false,
        ),
      );
      notifyListeners();
    } catch (err) {
      print(err);
      HttpException('Internal server error');
    }
  }

  Future<void> updateOrder(String id) async {
    try {
      print('i got here');
      final url =
          'https://shopapp-60226.firebaseio.com/order/$userId/$id.json?auth=$authToken';
      final response = await http.patch(url,
          body: json.encode({
            'paid': true,
          }));
      print(response.body);
      var orderIndex = _orders.indexWhere((order) => order.id == id);
      _orders[orderIndex].paid = true;
      notifyListeners();
    } catch (err) {
      print(err);
      HttpException('Internal server error');
    }
  }
}
