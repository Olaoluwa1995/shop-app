import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;

  Future<void> _authenticate(
      String email, String password, String urlSegement) async {
    try {
      final url =
          'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegement?key=AIzaSyBEelEr1Cmj93rf8JjzIo0qVFx_WQteQCs';
      final response = await http.post(
        url,
        body: json.encode({
          'email': email,
          'password': password,
          'returnSecureToken': true,
        }),
      );
      print(json.decode(response.body));
      final reponseData = json.decode(response.body);
      if (reponseData['error'] != null) {
        throw HttpException(reponseData['error']['message']);
      }
    } catch (err) {
      throw err;
    }
  }

  Future<void> signUp(String email, String password) async {
    return _authenticate(email, password, 'signUp');
  }

  Future<void> signIn(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }
}
