import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicine_chest/entities/medicine.dart';

import '../pages/add_scheme_page.dart';
import '../pages/root_navigation_page.dart';
import '../pages/schemes_list_page.dart';
import '../test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Scheme', () {
    testWidgets('Creation of new scheme', (tester) async {
      final deps = await createTestApp(tester);

      const medicineName = "Витамин Д";

      final medicine = Medicine(
          id: 1, name: medicineName, releaseForm: MedicineReleaseForm.liquid);

      // Создаем существующее лекарство
      await deps.medicineStorage.saveMedicine(medicine);

      final rootPage = TestRootNavigationPage(tester);

      //Открываем список схем
      await rootPage.openSchemesList();

      // Открываем добавление схемы
      final schemesListPage = TestSchemesListPage(tester);
      await schemesListPage.clickOnAddFab();

      // Заполняем размер дозы
      final addSchemePage = TestAddSchemePage(tester);
      await addSchemePage.fillTakeAmount("23");

      // Вводим время приема
      await addSchemePage.clickOnAddTime();
      await enterTime(tester, 2, 3);

      // Сохраняем схему приема
      await addSchemePage.clickOnSave();

      // Проверяем наличие новой схемы в списке схем
      await schemesListPage.expectSchemeExists(medicineName, 1);
    });
  });
}
