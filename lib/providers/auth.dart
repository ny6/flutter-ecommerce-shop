import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/models.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

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

    notifyListeners();
  }

  Future<void> signup(String email, String password) =>
      _authenticate(email, password, 'signUp');

  Future<void> signin(String email, String password) =>
      _authenticate(email, password, 'signInWithPassword');
}
