import "package:flutter/material.dart";
import "package:provider/provider.dart";

import '../widgets/drawer.dart';
import "../providers/cart.dart";
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import "../widgets/product_grid.dart";

import "../providers/products.dart";

enum FilterOptions { All, Favorites }

class ProductsOverviewScreen extends StatefulWidget {
  const ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool showFav = false;
  bool isLoading = false;

  @override
  void initState() {
    // print('running');
    //1. // Future.delayed(Duration.zero)
    //     .then((value) => Provider.of<Products>(context).fetchData());
    //2.   // Provider.of<Products>(context,listen: false).fetchData();
    super.initState();
  }

  //3.
  @override
  void didChangeDependencies() {
    setState(() {
      isLoading = true;
    });
    Provider.of<Products>(context, listen: false).fetchData().then((_) {
      setState(() {
        isLoading = false;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text("My Shop"),
        actions: [
          PopupMenuButton(
            onSelected: (sel) {
              // if (sel == FilterOptions.Favorites) {
              //   productsProvider.showFavs();
              // } else {
              //   productsProvider.showAll();
              // }
              if (sel == FilterOptions.Favorites) {
                setState(() {
                  showFav = true;
                });
              } else {
                setState(() {
                  showFav = false;
                });
              }
            },
            itemBuilder: (c) => [
              const PopupMenuItem(
                value: FilterOptions.Favorites,
                child: Text('Favorites'),
              ),
              const PopupMenuItem(
                value: FilterOptions.All,
                child: Text('Show All'),
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (_, cart, ch) => Badge(
              value: cart.getCount.toString(),
              child: ch as Widget,
            ),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ProductGrid(showFav),
    );
  }
}
