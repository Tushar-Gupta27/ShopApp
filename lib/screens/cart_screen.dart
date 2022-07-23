import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../providers/cart.dart" show Cart;
import '../widgets/cart_item.dart' as CartItem;
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = "/cart";
  const CartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Chip(
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text('\$${cart.getTotal.toStringAsFixed(2)}',
                        style: const TextStyle(color: Colors.white)),
                  ),
                  //Can add a loader in place of ORDER NOW by extracting it in a stateful widget and doing same thing
                  TextButton(
                    onPressed: cart.getTotal ==0 ? null : () async {
                      try {
                        await Provider.of<Orders>(context, listen: false)
                            .addOrder(
                                cart.getItems.values.toList(), cart.getTotal);
                        cart.clearCart();
                      } catch (e) {
                        print(e);
                      }
                    },
                    style: TextButton.styleFrom(primary: Colors.purple),
                    child: const Text(
                      'ORDER NOW',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CartItem.CartItem(
                  cart.getItems.values.toList()[i].id,
                  cart.getItems.values.toList()[i].title,
                  cart.getItems.values.toList()[i].price,
                  cart.getItems.values.toList()[i].quantity,
                  cart.getItems.keys.toList()[i]),
              itemCount: cart.getCount,
            ),
          )
        ],
      ),
    );
  }
}
