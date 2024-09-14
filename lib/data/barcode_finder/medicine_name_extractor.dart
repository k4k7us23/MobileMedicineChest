import 'dart:convert';

import 'package:medicine_chest/data/barcode_finder/giga_chat_token_provider.dart';

import 'package:http/http.dart' as http;

class MedicineNameExtractor {

  static const String _baseUrl = "https://gigachat.devices.sberbank.ru/api/v1/chat/completions";

  final _tokenProvider = GigaChatTokenProvider();

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

    final response = await http.post(
      headers: headers,
      body: jsonEncode(payloadMap),
      Uri.parse(_baseUrl)
    );

    String body = response.body;
    final responseJson = jsonDecode(body);
    String modelResponse = responseJson["choices"][0]["message"]["content"];
    return modelResponse;
  }

  List<Map<String, String>> _buildMessages(String productName) {
    List<Map<String, String>> result = [
      {
        "role": "system",
        "content":
            "Найди в сообщении пользователя название лекарства. Твой ответ должен состоять только из названия лекарства.",
      },
      {"role": "user", "content": productName}
    ];
    return result;
  }
}
