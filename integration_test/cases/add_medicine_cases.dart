import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';

import '../pages/add_medicine_page.dart';
import '../pages/medicine_list_page.dart';
import '../pages/root_navigation_page.dart';
import '../test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Medicines and pack creation', () {
    testWidgets('Add new medicine', (tester) async {
      final deps = await createTestApp(tester);

      final rootPage = TestRootNavigationPage(tester);
      // Открываем список лекарств
      await rootPage.openMedicinesList();

      // Кликаем на кнопку добавления лекарства
      final medicineListPage = TestMedicineListPage(tester);
      await medicineListPage.clickAddMedicineFab();

      // Проверяем, что раздел выбрать существующее не активен
      final addMedicinePage = TestAddMedicinePage(tester);
      await addMedicinePage.ensureSelectMedicineIsNotActive();

      // Заполняем название
      const medicineName = "Витамин Д";
      await addMedicinePage.fillMedicineName(medicineName);

      // Кликаем на сохранение лекарства
      await addMedicinePage.clickMedicineSave();

      // Проверяем, что появилась ошибка "Остаток не может быть пустым"
      await addMedicinePage.expectEmptyLeftAmountError();

      // Заполняем остаток лекарства
      await addMedicinePage.fillLeftAmount("23");

      // Кликаем на сохранение лекарства
      await addMedicinePage.clickMedicineSave();

      // Проверяем, что на экране списка лекарств появилось новое лекарство
      await medicineListPage.expectMedicineNameVisible(medicineName);
    });

    testWidgets('Add new pack to exisitng medicine', (tester) async {
      final deps = await createTestApp(tester);
      const medicineName = "Витамин Д";

      final medicine = Medicine(
          id: 1,
          name: medicineName,
          releaseForm: MedicineReleaseForm.liquid);

      // Создаем существующее лекарство
      await deps.medicineStorage.saveMedicine(medicine);

      // Создаем существующую упаковку
      await deps.medicinePackStorage.saveMedicinePack(MedicinePack(
          id: 1,
          leftAmount: 23,
          medicine: medicine,
          expirationTime: DateTime.now().add(Duration(days: 23))));

      final rootPage = TestRootNavigationPage(tester);
      // Открываем список лекарств
      await rootPage.openMedicinesList();

      // Кликаем на кнопку добавления лекарства
      final medicineListPage = TestMedicineListPage(tester);
      await medicineListPage.clickAddMedicineFab();

      // Проверяем, что раздел выбрать существующее активен
      final addMedicinePage = TestAddMedicinePage(tester);
      await addMedicinePage.ensureSelectMedicineIsActive();

      // Заполняем остаток лекарства
      await addMedicinePage.fillLeftAmount("20");

      // Кликаем на сохранение лекарства
      await addMedicinePage.clickMedicineSave();

      // Проверяем остаток лекарства
      // 20 + 23 = 43 (суммарный остаток двух упаковок)
      await medicineListPage.expectMedicineLeftAmount("43.00"); 
    });
  });
}
