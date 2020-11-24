import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';
import '../widgets/app_drawer.dart';

class OrderScreen extends StatelessWidget {
  static const routeName = '/order';
  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Orders'),
      ),
      drawer: AppDrawer(),
      body: orderData.orders.length > 0
          ? ListView.builder(
              itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
              itemCount: orderData.orders.length,
            )
          : Column(children: [
              Center(
                child: Container(
                  width: double.infinity,
                  height: 250,
                  margin: const EdgeInsets.only(top: 60),
                  child: Image.network(
                      'https://cdn.dribbble.com/users/1168645/screenshots/3152485/no-orders_2x.png'),
                ),
              ),
              Text(
                'No Orders!!',
                style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              )
            ]),
    );
  }
}
