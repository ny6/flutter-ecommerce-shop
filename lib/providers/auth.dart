import 'dart:convert';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

const userDataKey = 'userData';
const tokenKey = 'token';
const userIdKey = 'userId';
const expiryDateKey = 'expiryDate';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  Timer _authTimer;

  String get token {
    if (_token != null &&
        _expiryDate != null &&
        _expiryDate.isAfter(DateTime.now())) {
      return _token;
    }

    return null;
  }

  bool get isAuth => token != null;

  Future<void> _authenticate(
    String email,
    String password,
    String urlSegment,
  ) async {
    final url =
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyBiKpfNeopHs4mRAjMLS1UEUFtsZdHcAAY';

    final body = json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    });

    final res = await http.post(url, body: body);

    final parsedBody = json.decode(res.body);

    if (parsedBody['error'] != null) {
      throw HttpException(parsedBody['error']['message']);
    }

    _token = parsedBody['idToken'];
    _userId = parsedBody['localId'];
    _expiryDate = DateTime.now().add(Duration(
      seconds: int.parse(parsedBody['expiresIn']),
    ));
    _autoLogout();

    notifyListeners();

    final prefs = await SharedPreferences.getInstance();

    final userData = json.encode({
      tokenKey: _token,
      userIdKey: _userId,
      expiryDateKey: _expiryDate.toIso8601String(),
    });

    prefs.setString(userDataKey, userData);
  }

  Future<void> signup(String email, String password) =>
      _authenticate(email, password, 'signUp');

  Future<void> signin(String email, String password) =>
      _authenticate(email, password, 'signInWithPassword');

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey(userDataKey)) return false;

    final userData =
        json.decode(prefs.get(userDataKey)) as Map<String, dynamic>;

    final expiryDate = DateTime.parse(userData[expiryDateKey]);
    if (expiryDate.isBefore(DateTime.now())) return false;

    _token = userData[tokenKey];
    _userId = userData[userIdKey];
    _expiryDate = expiryDate;

    notifyListeners();
    _autoLogout();

    return true;
  }

  Future<void> logout() async {
    _token = null;
    _userId = null;
    _expiryDate = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove(userDataKey);
    prefs.clear();
  }

  void _autoLogout() {
    if (_authTimer != null) _authTimer.cancel();

    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logout);
  }
}
