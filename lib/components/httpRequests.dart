

import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Requests {
  static Future<Map> fetchFromServer(schoolId, username, password) async {
    final response = await http.get('http://159.65.72.108:15651/UserInfo?schoolId=$schoolId&username=$username&password=$password');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {};
    }
  }
  static Future<dynamic> makeRequest(String path) async {
    final response = await http.get('http://159.65.72.108:15651/$path');
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return [];
    }
  }
  static Future<dynamic> postRequest(String path, Map body) async {
    final response = await http.post('http://159.65.72.108:15651/$path', body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {};
    }
  }
}


