import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../mocks/mock_navigator_observer.dart';

class BuildContextProvider {
  static Future<BuildContext> get(WidgetTester tester) async {
    late BuildContext buildContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            buildContext = context;
            return const SizedBox();
          },
        ),
      ),
    );

    return buildContext;
  }

  static Future<BuildContext> getWithObserver(
    WidgetTester tester,
    TestNavigatorObserver observer,
  ) async {
    late BuildContext buildContext;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              buildContext = context;
              return const SizedBox();
            },
          ),
        ),
        navigatorObservers: [observer],
      ),
    );

    return buildContext;
  }
}
