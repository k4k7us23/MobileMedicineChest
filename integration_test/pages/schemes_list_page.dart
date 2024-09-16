import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

class TestSchemesListPage {

  WidgetTester _tester;

  TestSchemesListPage(this._tester);

  Future<void> clickOnAddFab() async {
    final saveMedicineFab = find.byKey(ValueKey("add_scheme_btn"));
    await _tester.tap(saveMedicineFab);
    await Future.delayed(Duration(seconds: 2));
    await _tester.pumpAndSettle();
  }

  Future<void> expectSchemeExists(String medicineName, int takeCount) async {
    final medicineTitleWidiget = find.byKey(ValueKey("scheme_medicine_name"));
    await _tester.ensureVisible(medicineTitleWidiget);
    final widgetText = medicineTitleWidiget.evaluate().single.widget as Text;
    expect(widgetText.data, medicineName);

    final takeCountWidiget = find.byKey(ValueKey("scheme_take_count"));
    await _tester.ensureVisible(takeCountWidiget);
    final widgetText2 = takeCountWidiget.evaluate().single.widget as Text;
    expect(widgetText2.data, "$takeCount раз в день");
  }
}