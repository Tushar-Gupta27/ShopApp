import "package:flutter/material.dart";

import 'package:provider/provider.dart';

import "../providers/products.dart";
import './product_item.dart';

class ProductGrid extends StatelessWidget {
  final bool showFav;

  ProductGrid(this.showFav);
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<Products>(context);
    final loadedProducts =
        showFav ? productsProvider.favItems : productsProvider.getItems;
    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 5 / 4,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
      ),
      itemCount: loadedProducts.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        value: loadedProducts[i],
        // create: (context) => loadedProducts[i],
        child: ProductItem(),
      ),
    );
  }
}
