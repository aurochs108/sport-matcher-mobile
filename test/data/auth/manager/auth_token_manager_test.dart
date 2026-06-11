import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

import 'auth_token_manager_test.mocks.dart';

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

    test('isSessionAuthenticated sets authenticated when token is available', () async {
      final tokens = _tokens(
        expiresAt: now.add(const Duration(minutes: 5)),
      );
      final emittedStates = _listenToAuthStateStreamAndStubTokens(
        sut: sut,
        tokenDatabase: tokenDatabase,
        tokens: tokens,
      );

      await pumpEventQueue();
      await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(sut.authState, AuthState.authenticated);
      expect(emittedStates, [null, AuthState.authenticated]);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated sets unauthenticated without tokens', () async {
      final emittedStates = _listenToAuthStateStreamAndStubTokens(
        sut: sut,
        tokenDatabase: tokenDatabase,
        tokens: null,
      );

      await pumpEventQueue();
      await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(sut.authState, AuthState.unauthenticated);
      expect(emittedStates, [null, AuthState.unauthenticated]);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated refreshes expired tokens', () async {
      final tokens = _tokens(
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      final emittedStates = _listenToAuthStateStreamAndStubTokens(
        sut: sut,
        tokenDatabase: tokenDatabase,
        tokens: tokens,
      );
      when(
        authRepository.refreshTokens(),
      ).thenAnswer((_) async => const ApiSuccess<void>(null));

      await pumpEventQueue();
      await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(sut.authState, AuthState.authenticated);
      expect(emittedStates, [null, AuthState.authenticated]);
      verify(tokenDatabase.loadTokens()).called(1);
      verify(authRepository.refreshTokens()).called(1);
      verifyNever(authRepository.clearStoredTokens());
    });

    test('isSessionAuthenticated clears tokens when refresh fails', () async {
      final tokens = _tokens(
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      final emittedStates = _listenToAuthStateStreamAndStubTokens(
        sut: sut,
        tokenDatabase: tokenDatabase,
        tokens: tokens,
      );
      when(
        authRepository.refreshTokens(),
      ).thenAnswer((_) async => const ApiError<void>('Refresh failed'));
      when(
        authRepository.clearStoredTokens(),
      ).thenAnswer((_) async => const ApiSuccess<void>(null));

      await pumpEventQueue();
      await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(sut.authState, AuthState.unauthenticated);
      expect(emittedStates, [null, AuthState.unauthenticated]);
      verify(tokenDatabase.loadTokens()).called(1);
      verify(authRepository.refreshTokens()).called(1);
      verify(authRepository.clearStoredTokens()).called(1);
    });

    test('isSessionAuthenticated sets unauthenticated on storage error', () async {
      final emittedStates = _listenToAuthStateStream(sut);
      when(tokenDatabase.loadTokens()).thenThrow(Exception('read failed'));

      await pumpEventQueue();
      await sut.isSessionAuthenticated();
      await pumpEventQueue();

      expect(sut.authState, AuthState.unauthenticated);
      expect(emittedStates, [null, AuthState.unauthenticated]);
      verify(tokenDatabase.loadTokens()).called(1);
      verifyNever(authRepository.refreshTokens());
      verifyNever(authRepository.clearStoredTokens());
    });
  });
}

List<AuthState?> _listenToAuthStateStreamAndStubTokens({
  required AuthTokenManager sut,
  required MockAuthTokensDatabase tokenDatabase,
  required AuthTokensEntity? tokens,
}) {
  final emittedStates = _listenToAuthStateStream(sut);
  when(tokenDatabase.loadTokens()).thenAnswer((_) async => tokens);
  return emittedStates;
}

List<AuthState?> _listenToAuthStateStream(AuthTokenManager sut) {
  final emittedStates = <AuthState?>[];
  final subscription = sut.authStateStream.listen(emittedStates.add);
  addTearDown(subscription.cancel);
  return emittedStates;
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
