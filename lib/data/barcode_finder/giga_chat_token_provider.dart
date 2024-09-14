import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import 'package:medicine_chest/config/secrets.dart' as secrets;

class GigaChatTokenProvider {
  static const String _baseUrl = 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth';

  String? _currentToken = null;
  DateTime? _expirationTime = null;

  final _uuid = Uuid();

  Future<String?> getToken() async {
    if (_currentToken != null &&
        (_expirationTime == null || DateTime.now().isBefore(_expirationTime!))) {
      return _currentToken;
    } else {
      await _requestNewToken();
      return _currentToken;
    }
  }

  Future<void> _requestNewToken() async {
    var headers = {
      'Content-Type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Authorization': 'Basic ${secrets.gigaChatAuthString}'
    };
    headers['RqUID'] = _uuid.v4();
    final response = await http.post(
      headers: headers,
      body: "scope=GIGACHAT_API_PERS",
      Uri.parse(_baseUrl)
    );
    String body = response.body;
    final responseJson = jsonDecode(body);

    _currentToken = responseJson["access_token"];
    _expirationTime = DateTime.fromMillisecondsSinceEpoch(responseJson["expires_at"] as int);
  }
}
