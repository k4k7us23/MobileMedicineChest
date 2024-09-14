import 'dart:convert';
import 'dart:io';

import 'package:medicine_chest/data/barcode_finder/giga_chat_token_provider.dart';
import 'package:medicine_chest/data/network/http_client_provider.dart';

class MedicineNameExtractor {
  static const String _baseUrl = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions";

  final _tokenProvider = GigaChatTokenProvider();

  final Future<HttpClient> _httpClientFuture = getHttpClient();
  
  Future<String?> extractMedicineName(String productName) async {
    String? token = await _tokenProvider.getToken();
    if (token == null) {
      throw Exception("Failed to get GigaChat api token");
    }

    Map<String, dynamic> payloadMap = {};
    payloadMap["model"] = "GigaChat";
    payloadMap["messages"] = _buildMessages(productName);

    var headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token'
    };

    HttpClient httpClient = await _httpClientFuture;
    try {
      final request = await httpClient.postUrl(Uri.parse(_baseUrl));
      request.headers.set(HttpHeaders.contentTypeHeader, 'application/json');
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $token');

      request.add(utf8.encode(jsonEncode(payloadMap)));

      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        String responseBody = await response.transform(utf8.decoder).join();
        final responseJson = jsonDecode(responseBody);
        String modelResponse = responseJson["choices"][0]["message"]["content"];
        return modelResponse;
      } else {
        throw HttpException('Failed to get medicine name: ${response.statusCode}');
      }
    } finally {
      httpClient.close();
    }
  }

  List<Map<String, String>> _buildMessages(String productName) {
    return [
      {
        "role": "system",
        "content":
            "Найди в сообщении пользователя название лекарства. Твой ответ должен состоять только из названия лекарства.",
      },
      {"role": "user", "content": productName}
    ];
  }
}
