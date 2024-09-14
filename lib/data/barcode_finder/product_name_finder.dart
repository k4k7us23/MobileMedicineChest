import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:medicine_chest/config/secrets.dart' as secrets;

class ProductNameFinder {

  static const int _statusOk = 200;

  Future<String?> getProductName(String barcode) async {
    final response = await http.get(Uri.parse(
        "https://barcodes.olegon.ru/api/card/name/$barcode/${secrets.barcodeDatabaseApiKey}"));

    if (response.statusCode == _statusOk) {
      Map<String, dynamic> jsonBody = jsonDecode(response.body);
      int statusCodeInBody = jsonBody["status"] as int;
      if (statusCodeInBody == _statusOk) {
          List<dynamic> names = jsonBody["names"];
          return names.firstOrNull as String;
      }
    } else {
      return null;
    }
  }
}
