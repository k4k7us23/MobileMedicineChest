import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicine_chest/ui/medicine_list/medicine_packs_title_widget.dart';

class TestMedicineListPage {
  WidgetTester _tester;

  TestMedicineListPage(this._tester);

  Future<void> clickAddMedicineFab() async {
    final addMedicineButton = find.byKey(ValueKey("add_medicine_btn"));
    await _tester.tap(addMedicineButton);
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> expectMedicineNameVisible(String medicineName) async {
    final medicineListItemWidget =
        find.byKey(ValueKey("medicine_title_widget"));
    await _tester.ensureVisible(medicineListItemWidget);
    final widgetText = medicineListItemWidget.evaluate().single.widget as Text;
    expect(widgetText.data, medicineName);
  }

  Future<void> expectMedicineLeftAmount(String leftAmount) async {
    final medicineTitleLeftAmountWidiget =
        find.byKey(ValueKey("medicine_title_left_amount"));
    await _tester.ensureVisible(medicineTitleLeftAmountWidiget);
    final widgetText =
        medicineTitleLeftAmountWidiget.evaluate().single.widget as Text;
    expect(widgetText.data, "Остаток: $leftAmount");
  }

  Future<void> clickOnMedicineTitle(String medicineName) async {
    await _tester.tap(find.descendant(
        of: find.widgetWithText(MedicinePacksTitleWidget, medicineName),
        matching: find.byKey(ValueKey("medicine_title_widget"))));
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }

  Future<void> expectMedicineExpireAt(String date) async {
    final medicineTitleLeftAmountWidiget =
        find.byKey(ValueKey("medicine_expire_at_text"));
    await _tester.ensureVisible(medicineTitleLeftAmountWidiget);
    final widgetText =
        medicineTitleLeftAmountWidiget.evaluate().single.widget as Text;
    expect(widgetText.data, "Срок годности: $date");
  }

  Future<void> expectMedicineExpired() async {
    final medicineTitleLeftAmountWidiget =
        find.byKey(ValueKey("medicine_expired_text"));
    await _tester.ensureVisible(medicineTitleLeftAmountWidiget);
  }
}
