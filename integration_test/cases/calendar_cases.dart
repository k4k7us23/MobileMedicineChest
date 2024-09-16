import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medicine_chest/entities/every_day_schedule.dart';
import 'package:medicine_chest/entities/medicine.dart';
import 'package:medicine_chest/entities/scheme.dart';

import '../pages/calendar_page.dart';
import '../pages/root_navigation_page.dart';
import '../pages/schemes_list_page.dart';
import '../test_utils.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  group('Calendar', () {
    testWidgets('Empty schedule', (tester) async {
      final deps = await createTestApp(tester);
      
      //Открываем календарь
      final rootPage = TestRootNavigationPage(tester);
      await rootPage.openCalendar();

      final calendarPage = TestCalendarPage(tester);
      await calendarPage.expectNoEvents();
    });

    testWidgets('Two reminders in day', (tester) async {
      final deps = await createTestApp(tester);

      const medicineName = "Витамин Д";
      
      // Заполняем базу данных
      final medicine = Medicine(
          id: 1,
          name: medicineName,
          releaseForm: MedicineReleaseForm.liquid
      );  
      await deps.medicineStorage.saveMedicine(medicine);

      final scheme = Scheme(1, medicine, 1, EveryDaySchedule.create([100 * 60, 200 * 60], DateTime.now(), DateTime.now().add(Duration(days: 5))));
      await deps.schemeStorage.saveScheme(scheme);

      //Открываем календарь
      final rootPage = TestRootNavigationPage(tester);
      await rootPage.openMedicinesList();
      await rootPage.openCalendar();

      // Проверяем отображение напоминаний
      final calendarPage = TestCalendarPage(tester);
      await calendarPage.expectTakeReminder("01:40", medicineName);
      await calendarPage.expectTakeReminder("03:20", medicineName);
    });
  });
}
