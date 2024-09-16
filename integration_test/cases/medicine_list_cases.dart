import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

import '../pages/medicine_list_page.dart';
import '../pages/root_navigation_page.dart';
import '../test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Medicines list', () {
    testWidgets('Not yet expired', (tester) async {
      final deps = await createTestApp(tester);

      const medicineName = "Витамин Д";

      final medicine = Medicine(
          id: 1,
          name: medicineName,
          releaseForm: MedicineReleaseForm.liquid);

      // Создаем существующее лекарство
      await deps.medicineStorage.saveMedicine(medicine);

      final expirationTime = DateTime.now().add(Duration(days: 23));

      // Создаем существующую упаковку
      final pack = MedicinePack(
          id: 1,
          leftAmount: 23,
          medicine: medicine,
          expirationTime: expirationTime);
      await deps.medicinePackStorage.saveMedicinePack(pack);

      final rootPage = TestRootNavigationPage(tester);
      // Открываем список лекарств
      await rootPage.openMedicinesList();

      // Кликаем на секцию "Витамин Д"
      final medicineListPage = TestMedicineListPage(tester);
      await medicineListPage.clickOnMedicineTitle(medicineName);
      
      // Проверяем, что отображается лекарство с правильным сроком годности 
      await medicineListPage.expectMedicineExpireAt(pack.getFormattedExpirationTime());
    });

    testWidgets('Expired', (tester) async {
      final deps = await createTestApp(tester);

      const medicineName = "Витамин Д";

      final medicine = Medicine(
          id: 1,
          name: medicineName,
          releaseForm: MedicineReleaseForm.liquid);

      // Создаем существующее лекарство
      await deps.medicineStorage.saveMedicine(medicine);

      final expirationTime = DateTime.now().subtract(Duration(days: 23));

      // Создаем существующую упаковку
      final pack = MedicinePack(
          id: 1,
          leftAmount: 23,
          medicine: medicine,
          expirationTime: expirationTime);
      await deps.medicinePackStorage.saveMedicinePack(pack);

      final rootPage = TestRootNavigationPage(tester);
      // Открываем список лекарств
      await rootPage.openMedicinesList();

      // Кликаем на секцию "Витамин Д"
      final medicineListPage = TestMedicineListPage(tester);
      await medicineListPage.clickOnMedicineTitle(medicineName);
      
      // Проверяем, что отображается лекарство с истекшим сроком годности 
      await medicineListPage.expectMedicineExpired();
    });
  });
}
