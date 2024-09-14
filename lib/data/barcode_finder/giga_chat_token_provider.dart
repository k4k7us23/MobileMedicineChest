import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';
import 'package:medicine_chest/data/network/http_client_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:medicine_chest/config/secrets.dart' as secrets;

class GigaChatTokenProvider {
  static const String _baseUrl = 'https://ngw.devices.sberbank.ru:9443/api/v2/oauth';

  String? _currentToken;
  DateTime? _expirationTime;
  final Future<HttpClient> _httpClientFuture = getHttpClient();

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
      HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Basic ${secrets.gigaChatAuthString}',
      'RqUID': _uuid.v4(),
    };

    HttpClient httpClient = await _httpClientFuture;
    try {
      final request = await httpClient.postUrl(Uri.parse(_baseUrl));
      headers.forEach((key, value) {
        request.headers.set(key, value);
      });

      request.write("scope=GIGACHAT_API_PERS");

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String body = await response.transform(utf8.decoder).join();
        final responseJson = jsonDecode(body);

        _currentToken = responseJson["access_token"];
        _expirationTime = DateTime.fromMillisecondsSinceEpoch(responseJson["expires_at"] as int);
      } else {
        throw HttpException('Failed to get token: ${response.statusCode}');
      }
    } finally {
      httpClient.close();
    }
  }
}
