import "package:flutter/material.dart";

import "package:provider/provider.dart";

import '../screens/product_detail_screen.dart';
import "../providers/product.dart";
import "../providers/products.dart";
import "../providers/cart.dart";
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final scaff = ScaffoldMessenger.of(context);
    final auth = Provider.of<Auth>(context);
    //The reason we dont use the whole products array here is because, we need to listen to changes in products provider then and if we do that, it will cause re builds in this widget that are rather unnecessary, thats why its better to use a single product as provider.
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black54,
          leading: Consumer<Product>(
            builder: (ctx, product, _) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: Theme.of(context).backgroundColor,
              ),
              onPressed: () async {
                try {
                  await product.toggleFav(auth.getToken, auth.getUserId);
                } catch (er) {
                  scaff.showSnackBar(
                      const SnackBar(content: Text('Cant Like!')));
                }
              },
            ),
          ),
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.shopping_cart,
              color: Theme.of(context).backgroundColor,
            ),
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Added Item to the Cart'),
                // margin: const EdgeInsets.only(left: 10, right: 10, bottom: 50),
                //width and margin can't be used simultaneously
                //dismiss direction is direction in which snackbar can be dismissed
                dismissDirection: DismissDirection.startToEnd,
                behavior: SnackBarBehavior.floating,
                width: 250,
                // backgroundColor: Colors.yellow,
                duration: const Duration(milliseconds: 3000),
                action: SnackBarAction(
                  label: 'UNDO',
                  onPressed: () {
                    cart.deleteById(product.id);
                  },
                ),
              ));
            },
          ),
        ),
        child: GestureDetector(
            onTap: () {
              Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                  arguments: product.id);
            },
            child: Hero(
              tag: product.id,
              child: FadeInImage(
                placeholder:
                    AssetImage('assets/images/product-placeholder.png'),
                image: NetworkImage(product.imageUrl),
                fit: BoxFit.cover,
              ),
            )),
      ),
    );
  }
}
