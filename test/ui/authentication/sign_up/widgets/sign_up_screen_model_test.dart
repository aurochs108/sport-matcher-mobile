import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/ui/authentication/sign_up/widgets/sign_up_screen_model.dart';

import 'sign_up_screen_model_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  provideDummy<ApiResult<void>>(const ApiError<void>('dummy error'));

  group('SignUpScreenModel', () {
    late MockAuthRepository authRepository;
    late SignUpScreenModel sut;

    setUp(() {
      authRepository = MockAuthRepository();
      sut = SignUpScreenModel(
        authRepository: authRepository,
      );
    });

    test('register calls repository and clears previous error on success', () async {
      when(
        authRepository.registerWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).thenAnswer((_) async => ApiSuccess<void>(null));
      sut.errorMessage = 'previous error';

      await sut.register('user@example.com', 'strong-password');

      expect(sut.errorMessage, isNull);
      verify(
        authRepository.registerWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).called(1);
    });

    final errorTestCases = <({
      String description,
      ApiError<void> repositoryResult,
      String expectedErrorMessage,
    })>[
      (
        description: 'stores repository error message on generic error',
        repositoryResult: ApiError<void>(
          'Registration failed',
          statusCode: 500,
        ),
        expectedErrorMessage: 'Registration failed',
      ),
      (
        description:
            'maps EMAIL_ALREADY_REGISTERED to the user-friendly message',
        repositoryResult: ApiError<void>(
          'Backend duplicate message',
          statusCode: 409,
          code: 'EMAIL_ALREADY_REGISTERED',
        ),
        expectedErrorMessage:
            'This email is already in use. Please use a different email.',
      ),
    ];

    for (final testCase in errorTestCases) {
      test('register ${testCase.description}', () async {
        when(
          authRepository.registerWithEmail(
            email: 'user@example.com',
            password: 'strong-password',
          ),
        ).thenAnswer((_) async => testCase.repositoryResult);

        await sut.register('user@example.com', 'strong-password');

        expect(sut.errorMessage, testCase.expectedErrorMessage);
      });
    }

    test('register clears previous error before a successful retry', () async {
      when(
        authRepository.registerWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).thenAnswer((_) async => const ApiError('Initial failure', statusCode: 500));

      await sut.register('user@example.com', 'strong-password');

      expect(sut.errorMessage, 'Initial failure');
      when(
        authRepository.registerWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).thenAnswer((_) async => ApiSuccess<void>(null));

      await sut.register('user@example.com', 'strong-password');

      expect(sut.errorMessage, isNull);
      verify(
        authRepository.registerWithEmail(
          email: 'user@example.com',
          password: 'strong-password',
        ),
      ).called(2);
    });
  });
}
