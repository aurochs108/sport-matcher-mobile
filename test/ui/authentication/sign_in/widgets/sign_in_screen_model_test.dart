import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/ui/authentication/sign_in/widgets/sign_in_screen_model.dart';
import 'package:sport_matcher/ui/bottom_navigation_bar/widgets/bottom_navigation_bar_screen.dart';

import '../../../../mocks/mock_navigator_observer.dart';
import '../../../../utilities/build_context_provider.dart';
import '../../../../utilities/snack_bar_assertions.dart';
import 'sign_in_screen_model_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<ApiResult<void>>(const ApiError<void>('dummy error'));

  group('SignInScreenModel', () {
    late MockAuthRepository authRepository;
    late SignInScreenModel sut;

    setUp(() {
      authRepository = MockAuthRepository();
      sut = SignInScreenModel(authRepository: authRepository);
    });

    testWidgets(
      'login calls repository, clears previous error, and navigates to tabbar',
      (WidgetTester tester) async {
        when(
          authRepository.loginWithEmail(
            email: 'user@example.com',
            password: 'strong-password',
          ),
        ).thenAnswer((_) async => ApiSuccess<void>(null));
        sut.errorMessage = 'previous error';
        final observer = TestNavigatorObserver();
        final buildContext =
            await BuildContextProvider.getWithObserverAndScaffold(
              tester,
              observer,
            );
        final navigator = Navigator.of(buildContext);
        final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

        await sut.login(
          'user@example.com',
          'strong-password',
          navigator,
          scaffoldMessenger,
        );
        await tester.pumpAndSettle();

        expect(sut.errorMessage, isNull);
        SnackBarAssertions.expectSnackBarIsNotVisible();
        verify(
          authRepository.loginWithEmail(
            email: 'user@example.com',
            password: 'strong-password',
          ),
        ).called(1);
        expect(observer.lastReplacedNewRoute, isA<MaterialPageRoute>());
        expect(find.byType(BottomNavigationBarScreen), findsOneWidget);
      },
    );

    testWidgets('login stores repository error and does not navigate', (
      WidgetTester tester,
    ) async {
      when(
        authRepository.loginWithEmail(
          email: 'user@example.com',
          password: 'wrong-password',
        ),
      ).thenAnswer((_) async => const ApiError<void>('Login failed'));
      final observer = TestNavigatorObserver();
      final buildContext = await BuildContextProvider.getWithObserverAndScaffold(
        tester,
        observer,
      );
      final navigator = Navigator.of(buildContext);
      final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

      await sut.login(
        'user@example.com',
        'wrong-password',
        navigator,
        scaffoldMessenger,
      );
      await tester.pump();

      expect(sut.errorMessage, 'Login failed');
      SnackBarAssertions.expectSnackBar(
        tester: tester,
        message: 'Login failed',
      );
      verify(
        authRepository.loginWithEmail(
          email: 'user@example.com',
          password: 'wrong-password',
        ),
      ).called(1);
      expect(observer.replaceCount, 0);
      expect(find.byType(BottomNavigationBarScreen), findsNothing);
    });

    testWidgets(
      'login maps invalid credentials code to user-friendly message',
      (WidgetTester tester) async {
        when(
          authRepository.loginWithEmail(
            email: 'user@example.com',
            password: 'wrong-password',
          ),
        ).thenAnswer(
          (_) async => const ApiError<void>(
            'Unauthorized. Please sign in again.',
            statusCode: 401,
            code: 'INVALID_LOGIN_CREDENTIALS',
          ),
        );
        final observer = TestNavigatorObserver();
        final buildContext =
            await BuildContextProvider.getWithObserverAndScaffold(
              tester,
              observer,
            );
        final navigator = Navigator.of(buildContext);
        final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

        await sut.login(
          'user@example.com',
          'wrong-password',
          navigator,
          scaffoldMessenger,
        );
        await tester.pump();

        expect(sut.errorMessage, 'Invalid login or password.');
        SnackBarAssertions.expectSnackBar(
          tester: tester,
          message: 'Invalid login or password.',
        );
        expect(observer.replaceCount, 0);
        expect(find.byType(BottomNavigationBarScreen), findsNothing);
      },
    );

    testWidgets('login shows snackbar when error exists', (
      WidgetTester tester,
    ) async {
      when(
        authRepository.loginWithEmail(
          email: 'user@example.com',
          password: 'wrong-password',
        ),
      ).thenAnswer((_) async => const ApiError<void>('Login failed'));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    await sut.login(
                      'user@example.com',
                      'wrong-password',
                      Navigator.of(context),
                      ScaffoldMessenger.of(context),
                    );
                  },
                  child: const Text('Login'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pump();

      SnackBarAssertions.expectSnackBar(
        tester: tester,
        message: 'Login failed',
      );
    });

    testWidgets('login does not show snackbar when error is null', (
      WidgetTester tester,
    ) async {
      when(
        authRepository.loginWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).thenAnswer((_) async => ApiSuccess<void>(null));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  onPressed: () async {
                    await sut.login(
                      'user@example.com',
                      'strong-password',
                      Navigator.of(context),
                      ScaffoldMessenger.of(context),
                    );
                  },
                  child: const Text('Login'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      SnackBarAssertions.expectSnackBarIsNotVisible();
    });
  });
}
