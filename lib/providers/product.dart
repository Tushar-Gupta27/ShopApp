import "package:flutter/material.dart";
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  // void toggleFav() {
  //   print(id);
  //   isFavorite = !isFavorite;
  //   notifyListeners();
  // }

  Future<void> toggleFav(String authToken, String userid) async {
    final url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/userFav/$userid/$id.json?auth=$authToken');
    bool? temp = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final res = await http.put(url, body: json.encode(isFavorite));
      if (res.statusCode >= 400) {
        isFavorite = temp;
        notifyListeners();
        throw HttpException('Cant Like');
      }
    } catch (er) {
      isFavorite = temp;
      notifyListeners();
      rethrow;
    }
  }
}
