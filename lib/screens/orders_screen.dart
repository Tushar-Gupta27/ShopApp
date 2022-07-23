import "package:flutter/material.dart";

import 'package:provider/provider.dart';
import '../widgets/drawer.dart';
import '../providers/orders.dart' show Orders;
import "../widgets/order_item.dart";

class OrdersScreen extends StatelessWidget {
  static const routeName = "/orders";

//IF FOR SOME REASON BUILD METHOD IS EXECUTED AGAIN AND AGAIN AN WE DONT NEED RECALLS
  // Future? _ordersFuture;
  // Future _obtainFuture() {
  //   return Provider.of<Orders>(context, listen: false).fetchData();
  // }
  // void initState() {
  //   _ordersFuture = _obtainFuture();
  //   super.initState();
  // }

// THE GENERIC METHOD FOR SHOWING A LOADING SPINNER USING A STATEFUL WIDGET AND FUTURES
  // @override
  // void initState() {
  //   Future.delayed(Duration.zero).then((value) async {
  //     setState(() {
  //       _isLoading = true;
  //     });
  //     await Provider.of<Orders>(context, listen: false).fetchData();
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   });
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    // final ordersData = Provider.of<Orders>(context);
    return Scaffold(
      drawer: MainDrawer(),
      appBar: AppBar(
        title: const Text('Your Orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchData(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else {
            // if (!snapshot.hasData) {
            //   return const Center(
            //     child: Text('No Orders'),
            //   );
            // }
            if (snapshot.error != null) {
              return const Center(
                child: Text('Something wrong happened'),
              );
            } else {
              return Consumer<Orders>(
                builder: (ctx, ordersData, _) {
                  return ListView.builder(
                    itemBuilder: (_, i) => OrderItem(
                      order: ordersData.getItems[i],
                    ),
                    itemCount: ordersData.getItems.length,
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}
