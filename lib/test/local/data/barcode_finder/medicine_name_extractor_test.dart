import 'package:medicine_chest/data/barcode_finder/medicine_name_extractor.dart';
import 'package:test/test.dart';

void main() {
  group("MedicineNameExtractor", () {
    var extractor = MedicineNameExtractor();
    test("ЦИНК ХЕЛАТ ЭВАЛАР 100 ТАБЛ", () async {
        String? medicineName = await extractor.extractMedicineName("ЦИНК ХЕЛАТ ЭВАЛАР 100 ТАБЛ");
        expect(medicineName, "Цинк Хелат Эвалар");
    });

    test("Ингавирин", () async {
        String? medicineName = await extractor.extractMedicineName("ИНГАВИРИН® ИМИДАЗОЛИЛЭТАНАМИД ПЕНТАНДИОВОЙ КИСЛОТЫ 90 МГ 10 КАПСУЛ");
        expect(medicineName, "Ингавирин");
    });
  });
}