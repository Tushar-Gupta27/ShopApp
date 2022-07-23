import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import "../providers/products.dart";

class ProductDetailScreen extends StatelessWidget {
  // const ProductDetailScreen({Key? key}) : super(key: key);
  static const routeName = '/product-detail';
  @override
  Widget build(BuildContext context) {
    final itemID = ModalRoute.of(context)?.settings.arguments as String;
    final product =
        Provider.of<Products>(context, listen: false).findById(itemID);
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   title: Text(product.title),
      // ),
      // CAN ADD FOR MULTIPLE STACKED APPBARS,TABBARS etc
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            // automaticallyImplyLeading: false,
            actions: [
              Container(
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.blueAccent.withOpacity(0.25)),
                child: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.add,
                      color: Colors.black,
                    )),
              )
            ],
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Transform(
                transform: Matrix4.translationValues(-25, 0, 0),
                child: Text(
                  product.title,
                ),
              ),
              background: Hero(
                tag: product.id,
                child: Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                const SizedBox(
                  height: 12,
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    children: [
                      Text(
                        '${product.price}',
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 24),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Text(
                        product.description,
                        softWrap: true,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 700,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
