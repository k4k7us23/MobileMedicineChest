import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestRootNavigationPage {
  WidgetTester _tester;

  TestRootNavigationPage(this._tester);

  Future<void> openMedicinesList() async {
    final medicinesPageButton = find.byKey(ValueKey("medicines_page"));
    await _tester.tap(medicinesPageButton);
    await Future.delayed(Duration(seconds: 1));
  }

  Future<void> openSchemesList() async {
    final medicinesPageButton = find.byKey(ValueKey("schemes_page"));
    await _tester.tap(medicinesPageButton);
    await Future.delayed(Duration(seconds: 1));
  }
}
