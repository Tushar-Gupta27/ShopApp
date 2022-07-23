import "package:flutter/material.dart";
import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';

import 'package:provider/provider.dart';
import "../providers/auth.dart";

class MainDrawer extends StatelessWidget {
  const MainDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          title: const Text("Hello Friend!"),
          automaticallyImplyLeading: false,
        ),
        // const Divider(),
        ListTile(
          title: const Text("Shop"),
          leading: const Icon(Icons.shop),
          onTap: () {
            Navigator.of(context).pushReplacementNamed('/');
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("Orders"),
          leading: const Icon(Icons.payment),
          onTap: () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("Products"),
          leading: const Icon(Icons.edit),
          onTap: () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName);
          },
        ),
        const Divider(),
        ListTile(
          title: const Text("Logout"),
          leading: const Icon(Icons.exit_to_app),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushReplacementNamed('/');
            Provider.of<Auth>(context, listen: false).logout();
          },
        ),
      ]),
    );
  }
}
