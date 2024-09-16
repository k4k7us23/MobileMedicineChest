import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestCalendarPage {
  WidgetTester _tester;

  TestCalendarPage(this._tester);

  Future<void> expectNoEvents() async {
    final medicineTitleLeftAmountWidiget =
        find.byKey(ValueKey("calendar_empty_day_text"));
    await _tester.ensureVisible(medicineTitleLeftAmountWidiget);
  }

  Future<void> expectTakeReminder(String time, String medicineName, {bool taken = false}) async {
    await _tester.ensureVisible(find.descendant(
        of: find.byKey(ValueKey("take_medicine_reminder_item_mainColumn")),
        matching: find.textContaining(medicineName)).first);
    await _tester.ensureVisible(find.descendant(
        of: find.byKey(ValueKey("take_medicine_reminder_item_time")),
        matching: find.textContaining(time)).first);
    if (taken) {
      await _tester.ensureVisible(find.descendant(
        of: find.byKey(ValueKey("take_medicine_reminder_item_mainColumn")),
        matching: find.textContaining("Принято")).first);
    } else {
      await _tester.ensureVisible(find.descendant(
        of: find.byKey(ValueKey("take_medicine_reminder_item_mainColumn")),
        matching: find.textContaining("Принять")).first);
    }
  }
}
