import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SnackBarAssertions {
  static void expectSnackBar({
    required WidgetTester tester,
    required String message,
    Color? backgroundColor,
  }) {
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text(message), findsOneWidget);

    if (backgroundColor != null) {
      final snackBar = tester.widget<SnackBar>(find.byType(SnackBar));
      expect(snackBar.backgroundColor, backgroundColor);
    }
  }

  static void expectSnackBarIsNotVisible() {
    expect(find.byType(SnackBar), findsNothing);
  }
}
