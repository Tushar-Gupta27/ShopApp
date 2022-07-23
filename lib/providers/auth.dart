import "dart:convert";
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'dart:async';
import "package:shared_preferences/shared_preferences.dart";

class Auth with ChangeNotifier {
  String? _token;
  DateTime? expiresIn;
  String? _userId;
  Timer? _authTimer;

  bool get isAuth {
    return getToken != null;
  }

  dynamic get getToken {
    if (_token != null &&
        expiresIn != null &&
        (expiresIn as DateTime).isAfter(DateTime.now())) {
      return _token as String;
    } else {
      return null;
    }
  }

  dynamic get getUserId {
    if (_token != null &&
        expiresIn != null &&
        (expiresIn as DateTime).isAfter(DateTime.now())) {
      return _userId as String;
    } else {
      return null;
    }
  }

  Future<void> signup(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=AIzaSyDuuI2Dwhd0AmXvO8pGEIkzfIrjq2TXq7c');
    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final fetched = json.decode(res.body);
      if (fetched['error'] != null) {
        throw HttpException(fetched['error']['message']);
      }
      _token = fetched['idToken'];
      expiresIn = DateTime.now()
          .add(Duration(seconds: int.parse(fetched['expiresIn'])));
      _userId = fetched['localId'];
      autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiresIn': expiresIn?.toIso8601String()
      });
      prefs.setString('userData', userData);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(String email, String password) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDuuI2Dwhd0AmXvO8pGEIkzfIrjq2TXq7c');
    try {
      final res = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true
          }));
      final fetched = json.decode(res.body);
      if (fetched['error'] != null) {
        throw HttpException(fetched['error']['message']);
      }
      _token = fetched['idToken'];
      expiresIn = DateTime.now()
          .add(Duration(seconds: int.parse(fetched['expiresIn'])));
      _userId = fetched['localId'];
      autoLogout();
      final prefs = await SharedPreferences.getInstance();
      final userData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiresIn': expiresIn?.toIso8601String()
      });
      prefs.setString('userData', userData);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('userData')) {
      return false;
    }
    final userData = json.decode(prefs.getString('userData') as String);
    final expiry = DateTime.parse(userData['expiresIn']);
    if (expiry.isBefore(DateTime.now())) {
      return false;
      //REFRESH TOKEN LOGIC GOES HERE
      //IF REFRESHTOKEN IS OUTDATED THEN BELOW PATHS STARTS
    }
    _token = userData['token'];
    _userId = userData['userId'];
    expiresIn = expiry;
    autoLogout();
    notifyListeners();
    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    expiresIn = null;
    if (_authTimer != null) {
      _authTimer?.cancel();
      _authTimer = null;
    }
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();

    notifyListeners();
  }

  void autoLogout() {
    if (_authTimer != null) {
      _authTimer?.cancel();
    }
    final timeToEnd = expiresIn?.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToEnd as int), logout);
    //REFRESH TOKEN LOGIC ALSO GOES TO LOGOUT, SO BEFORE LOGOUT WE TRY REFRESHING TOKEN
  }
}
