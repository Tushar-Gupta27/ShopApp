import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import "../providers/products.dart";
import '../screens/edit_products_screen.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;

  UserProductItem(this.id, this.title, this.imageUrl);
  @override
  Widget build(BuildContext context) {
    final scaff = ScaffoldMessenger.of(context);
    return Column(
      children: [
        ListTile(
          title: Text(title),
          leading: CircleAvatar(backgroundImage: NetworkImage(imageUrl)),
          trailing: Container(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  },
                  icon: const Icon(
                    Icons.edit,
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                IconButton(
                  onPressed: () async {
                    try {
                      await Provider.of<Products>(context, listen: false)
                          .deleteProduct(id);
                    } catch (e) {
                      scaff.showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Deleting Failed",
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(
                    Icons.delete,
                  ),
                  color: Theme.of(context).errorColor,
                )
              ],
            ),
          ),
        ),
        const Divider(),
      ],
    );
  }
}
