import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:intl/intl.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/medicine_pack.dart';
import 'package:medicine_chest/entities/scheme.dart';

import '../pages/add_take_page.dart';
import '../pages/calendar_page.dart';
import '../pages/root_navigation_page.dart';
import '../test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Take addition', () {
    testWidgets('Take addition', (tester) async {
      final deps = await createTestApp(tester);

      const medicineName = "Витамин Д";

      // Заполняем базу данных
      final medicine = Medicine(
          id: 1, name: medicineName, releaseForm: MedicineReleaseForm.liquid);
      await deps.medicineStorage.saveMedicine(medicine);

      final pack = MedicinePack(
          id: 1,
          leftAmount: 23,
          medicine: medicine,
          expirationTime: DateTime.now().add(Duration(days: 23)));
      await deps.medicinePackStorage.saveMedicinePack(pack);

      final hour = DateTime.now().hour;
      final minute = DateTime.now().minute;

      final nf = NumberFormat("00");

      final currentMinute = hour  * 60 + minute;

      final scheme = Scheme(
          1,
          medicine,
          1,
          EveryDaySchedule.create([currentMinute * 60], DateTime.now(),
              DateTime.now().add(Duration(days: 5))));
      await deps.schemeStorage.saveScheme(scheme);

      //Открываем календарь
      final rootPage = TestRootNavigationPage(tester);
      await rootPage.openMedicinesList();
      await rootPage.openCalendar();

      // Кликаем на принятие лекарства
      final calendarPage = TestCalendarPage(tester);
      await calendarPage.clickAddTakeRecord();

      // Заполняем размер дозы
      final addTakePage = TestAddTakePage(tester);
      await addTakePage.fillDosage("1");

      // Сохраняем прием лекарства
      await addTakePage.clickSave();

      final timeString = "${nf.format(hour)}:${nf.format(minute)}";

      // Проверяем содержимое календаря
      await calendarPage.expectTakeReminder(timeString, medicineName, taken: true);
    });
  });
}
