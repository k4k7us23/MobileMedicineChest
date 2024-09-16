import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAddTakePage {
  WidgetTester _tester;

  TestAddTakePage(this._tester);

  Future<void> fillDosage(String dosage) async {
    final dosageInput = find.byKey(ValueKey("take_medicine_dosage_input"));
    await _tester.enterText(dosageInput, dosage);
  }

  Future<void> clickSave() async {
    await _tester.tap(find.byKey(ValueKey("save_medicine_take")));
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }
}