import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

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
}
