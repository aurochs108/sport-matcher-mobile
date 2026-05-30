import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

import 'auth_manager_test.mocks.dart';

@GenerateMocks([AuthRepository, AuthTokensDatabase])
void main() {
  provideDummy<ApiResult<void>>(const ApiSuccess<void>(null));

  group('AuthTokenManager', () {
    late MockAuthRepository authRepository;
    late MockAuthTokensDatabase tokenDatabase;
    late AuthTokenManager sut;
    final now = DateTime(2026, 1, 1, 12);

    setUp(() {
      authRepository = MockAuthRepository();
      tokenDatabase = MockAuthTokensDatabase();
      sut = AuthTokenManager.forTesting(
        authRepository: authRepository,
        tokenDatabase: tokenDatabase,
        now: () => now,
      );
    });

    test('isSessionAuthenticated updates authState', () async {
      final tokens = _tokens(
        expiresAt: now.add(const Duration(minutes: 5)),
      );
      final emittedStates = <AuthState?>[];
      final subscription = sut.authStateStream.listen(emittedStates.add);
      addTearDown(subscription.cancel);
      when(tokenDatabase.loadTokens()).thenAnswer((_) async => tokens);

      await pumpEventQueue();
      final result = await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(result, AuthState.authenticated);
      expect(sut.authState, AuthState.authenticated);
      expect(emittedStates, [null, AuthState.authenticated]);
    });

    test('isSessionAuthenticated returns unauthenticated without tokens', () async {
      when(tokenDatabase.loadTokens()).thenAnswer((_) async => null);

      final result = await sut.isSessionAuthenticated();

      expect(result, AuthState.unauthenticated);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated returns authenticated for valid tokens', () async {
      final tokens = _tokens(
        expiresAt: now.add(const Duration(minutes: 5)),
      );
      when(tokenDatabase.loadTokens()).thenAnswer((_) async => tokens);

      final result = await sut.isSessionAuthenticated();

      expect(result, AuthState.authenticated);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated refreshes expired tokens', () async {
      final tokens = _tokens(
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      when(tokenDatabase.loadTokens()).thenAnswer((_) async => tokens);
      when(
        authRepository.refreshTokens(),
      ).thenAnswer((_) async => const ApiSuccess<void>(null));

      final result = await sut.isSessionAuthenticated();

      expect(result, AuthState.authenticated);
      verify(tokenDatabase.loadTokens()).called(1);
      verify(authRepository.refreshTokens()).called(1);
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated clears tokens when refresh fails', () async {
      final tokens = _tokens(
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      when(tokenDatabase.loadTokens()).thenAnswer((_) async => tokens);
      when(
        authRepository.refreshTokens(),
      ).thenAnswer((_) async => const ApiError<void>('Refresh failed'));
      when(
        authRepository.clearStoredTokens(),
      ).thenAnswer((_) async => const ApiSuccess<void>(null));

      final result = await sut.isSessionAuthenticated();

      expect(result, AuthState.unauthenticated);
      verify(tokenDatabase.loadTokens()).called(1);
      verify(authRepository.refreshTokens()).called(1);
      verify(authRepository.clearStoredTokens()).called(1);
    });

    test('isSessionAuthenticated returns unauthenticated on storage error', () async {
      when(tokenDatabase.loadTokens()).thenThrow(Exception('read failed'));

      final result = await sut.isSessionAuthenticated();

      expect(result, AuthState.unauthenticated);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });
  });
}

AuthTokensEntity _tokens({required DateTime expiresAt}) {
  return AuthTokensEntity(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
    tokenType: 'Bearer',
    expiresIn: 3600,
    accessTokenExpiresAtMillisecondsSinceEpoch:
        expiresAt.millisecondsSinceEpoch,
  );
}
