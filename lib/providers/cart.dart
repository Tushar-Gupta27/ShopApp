import 'dart:math';

import "package:flutter/material.dart";

class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(this.id, this.title, this.quantity, this.price);
}

class Cart with ChangeNotifier {
  //here the MAP, String refers to Product id and a specific CartItem for that product
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get getItems {
    return {..._items};
  }

  int get getCount {
    //returns number of key-value pairs
    return _items.length;
  }

  double get getTotal {
    double total = 0.0;
    _items.forEach((key, value) {
      total += value.quantity * value.price;
    });
    return total;
  }

  //can add only Item for each product in one time
  void addItem(String pId, String title, double price) {
    if (_items.containsKey(pId)) {
      //gives the previous value the key had
      _items.update(
          pId,
          (prev) =>
              CartItem(prev.id, prev.title, prev.quantity + 1, prev.price));
    } else {
      //adds in if the key is absent
      _items.putIfAbsent(
          pId,
          () => CartItem(DateTime.now().millisecondsSinceEpoch.toString(),
              title, 1, price));
    }
    notifyListeners();
  }

  void removeItem(String pid) {
    _items.remove(pid);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void deleteById(String pid) {
    if (!_items.containsKey(pid)) {
      return;
    }
    if ((_items[pid] as CartItem).quantity > 1) {
      _items.update(
          pid,
          (value) =>
              CartItem(value.id, value.title, value.quantity - 1, value.price));
    } else {
      _items.remove(pid);
    }
    notifyListeners();
  }
}
