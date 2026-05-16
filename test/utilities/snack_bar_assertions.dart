import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SnackBarAssertions {
  static void expectSnackBar({
    required WidgetTester tester,
    required String message,
  }) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
    expect(snackBar.backgroundColor, Colors.red);
  }

  static void expectSnackBarIsNotVisible() {
    expect(find.byType(SnackBar), findsNothing);
  }
}
