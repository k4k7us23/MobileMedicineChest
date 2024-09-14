import 'package:medicine_chest/data/barcode_finder/product_name_finder.dart';

import 'package:test/test.dart';

void main() {
  group('Known barcodes', () {
    test('Artelak', () async {
      final productNameFinder = ProductNameFinder();
      String? productName = await productNameFinder.getProductName("4029835000180");
      expect(productName, "АРТЕЛАК ВСПЛЕСК УНО В ТЮБ.-КАПЕЛЬН.0.5МЛ №30 ТЮБ.-КАПЕЛЬНИЦА 0.5МЛ, №30");
    });

    test('Nurofen', () async {
      final productNameFinder = ProductNameFinder();
      String? productName = await productNameFinder.getProductName("5000158107397");
      expect(productName, "НУРОФЕН®, ТАБЛЕТКИ, ПОКРЫТЫЕ ОБОЛОЧКОЙ, 200 МГ, 30 ТАБЛЕТОК");
    });
  });

  group('Unknown barcodes', () {
    test('Unknown barcode', () async {
      final productNameFinder = ProductNameFinder();
      String? productName = await productNameFinder.getProductName("23");
      expect(productName, null);
    });
  });
}