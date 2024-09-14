import 'package:medicine_chest/data/barcode_finder/giga_chat_token_provider.dart';
import 'package:test/test.dart';

void main() {
  group('GigaChatTokenProvider test', () {
    final tokenProvider = GigaChatTokenProvider();
    String? token = null;
    test('Receiving token', () async {
      token = await tokenProvider.getToken();
      expect(token, isNotNull);
    });

    test('Receiving token second time', () async {
      String? newToken = await tokenProvider.getToken();
      expect(token, newToken);
    });
  });
}
