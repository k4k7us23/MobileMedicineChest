import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAddMedicinePage {
  WidgetTester _tester;

  TestAddMedicinePage(this._tester);

  Future<void> ensureSelectMedicineIsNotActive() async {
    final selectExistingMedicineButton =
        find.byKey(ValueKey("select_existing_medicine"));
    await _tester.tap(selectExistingMedicineButton);
    await Future.delayed(Duration(seconds: 1));
    await _tester.ensureVisible(find.byKey(ValueKey("scan_barcode_btn")));
  }

  Future<void> ensureSelectMedicineIsActive() async {
    final selectExistingMedicineButton =
        find.byKey(ValueKey("select_existing_medicine"));
    await _tester.tap(selectExistingMedicineButton);
    await Future.delayed(Duration(seconds: 1));
    final scanBarcodeBtn = find.byKey(ValueKey("scan_barcode_btn"));
    expect(false, scanBarcodeBtn.tryEvaluate()); 
  }

  Future<void> fillMedicineName(String medicineName) async {
    final medicineNameInput = find.byKey(ValueKey("medicine_name_input"));
    await _tester.enterText(medicineNameInput, medicineName);
  }

  Future<void> clickMedicineSave() async {
    final saveMedicineFab = find.byKey(ValueKey("save_medicine_fab"));
    await _tester.tap(saveMedicineFab);
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }

  Future<void> fillLeftAmount(String leftAmount) async {
    final leftAmountInput = find.byKey(ValueKey("left_amount_input"));
    await _tester.enterText(leftAmountInput, leftAmount);
  }

  Future<void> expectEmptyLeftAmountError() async {
     await _tester.ensureVisible(find.text("Остаток не может быть пустым"));
  }
}
