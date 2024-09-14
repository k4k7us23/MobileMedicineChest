import 'package:medicine_chest/data/barcode_finder/medicine_name_extractor.dart';
import 'package:medicine_chest/data/barcode_finder/product_name_finder.dart';

sealed class BarcodeFinderResult {}

class Success extends BarcodeFinderResult {
  String medicineName;

  Success(this.medicineName);
}

class Error extends BarcodeFinderResult {
  String message;
  Object? cause;

  Error(this.message, {this.cause});
}

class BarcodeFinder {

  final _productNameFinder = ProductNameFinder();
  final _medicineNameExtractor = MedicineNameExtractor();

  Future<BarcodeFinderResult> find(String barcode) async {
    String? productName;
    try {
        productName = await _productNameFinder.getProductName(barcode);
    } catch (e) {
      return Error("Ошибка при поиске данных по штрих коду", cause: e);
    }
    if (productName == null) {
      return Error("Не удалось найти штрих-код в базе данных");
    }

    String? medicineName;
    try {
      medicineName = await _medicineNameExtractor.extractMedicineName(productName);
    } catch (e) {
      return Error("Ошибка при извлечении названия лекарства");
    }

    if (medicineName == null) {
      return Error("Не удалось извлечь название лекартсва");
    }

    return Success(medicineName);
  }
}