import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

class TestAddSchemePage {
  WidgetTester _tester;

  TestAddSchemePage(this._tester);

  Future<void> fillTakeAmount(String takeAmount) async {
    final leftAmountInput = find.byKey(ValueKey("scheme_amount_input"));
    await _tester.enterText(leftAmountInput, takeAmount);
  }

  Future<void> clickOnAddTime() async {
    await _tester.tap(find.byKey(ValueKey("scheme_add_time_btn")));
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }

  Future<void> clickOnSave() async {
    await _tester.tap(find.byKey(ValueKey("scheme_save_fab")));
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }
}
