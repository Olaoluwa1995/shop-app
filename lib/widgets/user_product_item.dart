import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem({this.id, this.title, this.imageUrl});
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Products>(context, listen: false);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                // print(i?÷d);
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text('Are you sure?'),
                    content: Text(
                      'Do you want to remove the item from the cart?',
                    ),
                    actions: [
                      FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(false);
                        },
                        child: Text('No'),
                      ),
                      FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(true);
                        },
                        child: Text('Yes'),
                      )
                    ],
                  ),
                );
                product.deleteProduct(id);
              },
              color: Theme.of(context).errorColor,
            ),
          ],
        ),
      ),
    );
  }
}
