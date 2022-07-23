import "package:flutter/material.dart";
import './cart.dart';

import 'package:http/http.dart' as http;
import "dart:convert";

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime datetime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.datetime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _items = [];
  final String? authToken;
  final String? userid;
  List<OrderItem> get getItems {
    return [..._items];
  }

  Orders(this.authToken, this.userid, this._items);

  Future<void> fetchData() async {
    final url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/orders/$userid.json?auth=$authToken');
    try {
      final List<OrderItem> orders = [];
      final res = await http.get(url);
      final fetched = json.decode(res.body) as Map<String, dynamic>;
      if (fetched.isEmpty) {
        return;
      }
      fetched.forEach((key, value) {
        orders.add(
          OrderItem(
            id: key,
            amount: value['amount'],
            products: (value['products'] as List<dynamic>)
                .map((e) =>
                    CartItem(e['id'], e['title'], e['quantity'], e['price']))
                .toList(),
            datetime: DateTime.parse(
              value['datetime'],
            ),
          ),
        );
      });
      _items = orders.reversed.toList();
      notifyListeners();
    } catch (err) {
      print(err);
      rethrow;
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double amount) async {
    final url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/orders/$userid.json?auth=$authToken');
    final time = DateTime.now();
    final res = await http.post(url,
        body: json.encode({
          'amount': amount,
          'datetime': time.toIso8601String(),
          'products': cartProducts
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList()
        }));

    _items.insert(
        0,
        OrderItem(
          id: json.decode(res.body)['name'],
          amount: amount,
          products: cartProducts,
          datetime: time,
        ));
    notifyListeners();
  }
}
