import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paystack_manager/paystack_manager.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  var _expanded = false;
  void _onPaymentSuccessful(Transaction transaction) {
    Provider.of<ord.Orders>(context, listen: false)
        .updateOrder(widget.order.id);
    Scaffold.of(context).hideCurrentSnackBar();
    Scaffold.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment Successful'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onPaymentPending(Transaction transaction) {
    print('Transaction Pending');
    print("Transaction Ref ${transaction.refrenceNumber}");
  }

  void _onPaymentFailed(Transaction transaction) {
    print('Transaction Failed');
    print("Transaction message ==> ${transaction.message}");
  }

  void _onCancel(Transaction transaction) {
    print('Transaction Cancelled');
  }

  var _successful = false;
  void _processPayment(amount, email, id) {
    try {
      int price = amount.round() * 100;
      print(email);

      PaystackPayManager(context: context)
        ..setSecretKey('sk_test_65f9f43211468f99557c97296b97bb541918f6f9')
        ..setCompanyAssetImage(
          Image(
            image: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQoo_k5zlEDSw9I_13JJesST_Fu3CfH-g--FA&usqp=CAU'),
          ),
        )
        ..setAmount(price)
        ..setEmail(email)
        ..setCurrency('NGN')
        ..setReference(DateTime.now().millisecondsSinceEpoch.toString())
        ..setMetadata(
          {
            "custom_fields": [
              {
                "value": "Charge Card", // set this your company name
                "display_name": "Paymyrent",
                "variable_name": "Busola"
              }
            ]
          },
        )
        ..onSuccesful(_onPaymentSuccessful)
        ..onPending(_onPaymentPending)
        ..onFailed(_onPaymentFailed)
        ..onCancel(_onCancel)
        ..initialize();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Auth>(context);
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height:
          _expanded ? max(widget.order.products.length * 20.0 + 150, 250) : 160,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            ListTile(
              title: Text('\$${widget.order.amount}'),
              subtitle: Text(
                DateFormat('dd-MM-y').add_jm().format(widget.order.dateTime),
              ),
              trailing: IconButton(
                icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _expanded = !_expanded;
                  });
                },
              ),
            ),
            AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              height: _expanded
                  ? min(widget.order.products.length * 20.0 + 20.0, 100.0)
                  : 0,
              child: ListView(
                  children: widget.order.products
                      .map(
                        (prod) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              prod.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              ('${prod.quantity} x \$${prod.price}'),
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      )
                      .toList()),
            ),
            if (!widget.order.paid)
              FlatButton(
                onPressed: () {
                  _processPayment(
                      widget.order.amount, user.email, widget.order.id);
                },
                child: Text('Make Payment'),
              ),
            if (widget.order.paid)
              Container(
                child: Padding(
                  child: Text(
                    'Paid',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  padding: const EdgeInsets.all(10),
                ),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(5)),
              )
          ],
        ),
      ),
    );
  }
}
