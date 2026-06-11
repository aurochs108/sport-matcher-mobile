import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/manager/auth_token_manager.dart';
import 'package:sport_matcher/ui/authentication/auth_gate/widgets/auth_gate_screen_model.dart';

import 'auth_gate_screen_model_test.mocks.dart';

@GenerateMocks([AuthTokenManager])
void main() {
  group('AuthGateScreenModel', () {
    late MockAuthTokenManager authTokenManager;
    late AuthGateScreenModel sut;

    setUp(() {
      authTokenManager = MockAuthTokenManager();
      sut = AuthGateScreenModel(authTokenManager: authTokenManager);
    });

    test('authState returns manager authState', () {
      when(
        authTokenManager.authState,
      ).thenReturn(AuthState.authenticated);

      expect(sut.authState, AuthState.authenticated);
      verify(authTokenManager.authState).called(1);
    });

    test('authStateStream returns manager authStateStream', () {
      final stream = Stream<AuthState?>.value(AuthState.unauthenticated);
      when(authTokenManager.authStateStream).thenAnswer((_) => stream);

      expect(sut.authStateStream, same(stream));
      verify(authTokenManager.authStateStream).called(1);
    });

    test('checkSession asks manager to validate session', () {
      when(
        authTokenManager.isSessionAuthenticated(),
      ).thenAnswer((_) async {});

      sut.checkSession();

      verify(authTokenManager.isSessionAuthenticated()).called(1);
    });
  });
}
