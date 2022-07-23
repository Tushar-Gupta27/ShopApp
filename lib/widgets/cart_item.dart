import 'dart:math';

import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import "../providers/cart.dart";

class CartItem extends StatelessWidget {
  final String title;
  final double price;
  final int quantity;
  final String id;
  final String pid;

  CartItem(this.id, this.title, this.price, this.quantity, this.pid);
  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(pid);
      },
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Are you Sure?"),
            content: const Text("Do you want to delete the item"),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, true);
                  },
                  child: const Text('Yes')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(ctx, false);
                  },
                  child: const Text('No')),
            ],
          ),
        );
      },
      background: Container(
        color: Theme.of(context).errorColor,
        padding: const EdgeInsets.all(8),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        alignment: Alignment.centerRight,
        child: const Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: FittedBox(
                  child: Text(
                    '$price',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('\$${(quantity * price)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
