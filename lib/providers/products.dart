import "package:flutter/material.dart";
import 'package:shop_app/models/http_exception.dart';
import 'product.dart';

import "dart:convert";
import "package:http/http.dart" as http;
import "./product.dart";

class Products with ChangeNotifier {
  List<Product> _items = [];

  // bool _favsOnly = false;

  final String? authToken;
  final String? userid;

  Products(this.authToken, this.userid, this._items);

  Future<void> fetchData([bool filter = false]) async {
    final filterString = filter ? '&orderBy="creatorId"&equalTo="$userid"' : "";
    var url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/products.json?auth=$authToken$filterString');
    try {
      final response = await http.get(url);
      final List<Product> tempProducts = [];
      final fetched = json.decode(response.body) as Map<String, dynamic>;
      if (fetched.isEmpty) {
        return;
      }
      url = Uri.parse(
          'https://flutter-shop-188d9-default-rtdb.firebaseio.com/userFav/$userid.json?auth=$authToken');
      final favResponse = await http.get(url);
      final favFetched = json.decode(favResponse.body);
      fetched.forEach((prodId, prod) {
        tempProducts.add(Product(
            id: prodId,
            title: prod['title'],
            description: prod['description'],
            price: prod['price'],
            imageUrl: prod['imageUrl'],
            isFavorite:
                favFetched == null ? false : favFetched[prodId] ?? false));
      });
      _items = tempProducts;
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  List<Product> get getItems {
    return [..._items];
    // if (_favsOnly) {
    //   return _items.where((item) => item.isFavorite).toList();
    // }
  }

  List<Product> get favItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Future<void> addProducts(Product pro) async {
    // final url = Uri.https(
    //     'https://flutter-shop-188d9-default-rtdb.firebaseio.com',
    //     '/products.json');
    final url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/products.json?auth=$authToken');
    //THEN CATCH BLOCK
    // return http
    //     .post(url,
    //         body: json.encode({
    //           "title": pro.title,
    //           "description": pro.description,
    //           "imageUrl": pro.imageUrl,
    //           "price": pro.price,
    //           "isFavorite": pro.isFavorite
    //         }))
    //     .then((response) {
    //   Product _edited = Product(
    //       id: json.decode(response.body)['name'],
    //       title: pro.title,
    //       description: pro.description,
    //       price: pro.price,
    //       imageUrl: pro.imageUrl);
    //   _items.insert(0, _edited);
    //   notifyListeners();
    // }).catchError((err) {
    //   throw err;
    // });
    try {
      final response = await http.post(url,
          body: json.encode({
            "title": pro.title,
            "description": pro.description,
            "imageUrl": pro.imageUrl,
            "price": pro.price,
            "creatorId": userid
          }));

      Product _edited = Product(
          id: json.decode(response.body)['name'],
          title: pro.title,
          description: pro.description,
          price: pro.price,
          imageUrl: pro.imageUrl);
      _items.insert(0, _edited);
      notifyListeners();
    } catch (err) {
      throw err;
    }
  }

  Future<void> editProducts(String id, Product pro) async {
    final index = _items.indexWhere((element) => element.id == id);
    if (index >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-188d9-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      try {
        await http.patch(url,
            body: json.encode({
              "title": pro.title,
              "description": pro.description,
              "imageUrl": pro.imageUrl,
              "price": pro.price
            }));
        _items[index] = pro;
        notifyListeners();
      } catch (err) {
        throw err;
      }
    }
  }

  Future<void> deleteProduct(String id) async {
    //EXAMPLE OF OPTIMISTIC UPDATING
    final url = Uri.parse(
        'https://flutter-shop-188d9-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final deletedIndex = _items.indexWhere((element) => element.id == id);
    var deletedItem = _items[deletedIndex];
    _items.removeWhere((element) => element.id == id);
    notifyListeners();
    final res = await http.delete(url);
    if (res.statusCode >= 400) {
      _items.add(deletedItem);
      notifyListeners();
      throw HttpException('Could not delete');
      //throw similar to return -> stops execution of code
    }

    deletedItem = null as Product;
  }
  //Now this approach will cause an filter throughout our APP which may not be needed,
  //If we need filter only on one screen, then it makes sense to use a stateful widget to toggle the filters
  //instead of causing a global filter (vid 201)
  // void showFavs() {
  //   _favsOnly = true;
  // notifyListener();
  // }

  // void showAll() {
  //   _favsOnly = false;
  // notifyListener();

  // }

  Product findById(String id) {
    return _items.firstWhere((item) => item.id == id);
  }
}
