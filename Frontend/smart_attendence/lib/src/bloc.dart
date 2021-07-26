import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class Bloc {
  Bloc(this.verified);
  String _token;
  bool verified = false;
  final String URL = '192.168.0.194:8000';
  Future login(username, password) async {
    print('im here');

    Uri baseurl = Uri.http(URL, '/accounts/login');
    var response = await http
        .post(baseurl, body: {'username': username, 'password': password});
    print(response.body);
    Map parse = json.decode(response.body);
    _token = parse['token'];
    this.verified = true;
    return this.verified;
  }
}
