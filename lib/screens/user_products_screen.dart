import "package:flutter/material.dart";
import "package:provider/provider.dart";

import "../widgets/user_product_item.dart";
import '../providers/products.dart';

import './edit_products_screen.dart';
import "../widgets/drawer.dart";

class UserProductsScreen extends StatelessWidget {
  static const routeName = "/user-products";
  const UserProductsScreen({Key? key}) : super(key: key);

  Future<void> _refresh(BuildContext ctx) async {
    // listen:false because we just want to call the function;
    await Provider.of<Products>(ctx, listen: false).fetchData(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Your Products'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context)
                  .pushNamed(EditProductScreen.routeName, arguments: '');
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _refresh(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refresh(context),
                    child: Consumer<Products>(
                      builder: (ctx, productsProvider, _) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: ListView.builder(
                          itemBuilder: (_, i) => UserProductItem(
                            productsProvider.getItems[i].id,
                            productsProvider.getItems[i].title,
                            productsProvider.getItems[i].imageUrl,
                          ),
                          itemCount: productsProvider.getItems.length,
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }
}
