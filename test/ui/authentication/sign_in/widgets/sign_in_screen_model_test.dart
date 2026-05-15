import 'package:flutter_test/flutter_test.dart';
import 'package:sport_matcher/data/auth/network/api/auth_api.dart';
import 'package:sport_matcher/data/auth/network/response/auth_tokens_reponse.dart';
import 'package:sport_matcher/data/auth/persistence/database/abstract_auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/device_id/repository/abstract_device_id_repository.dart';
import 'package:sport_matcher/ui/authentication/sign_in/widgets/sign_in_screen_model.dart';

void main() {
  group('SignInScreenModel', () {
    late _FakeAuthRepository authRepository;
    late int onLoginSuccessCallsCount;
    late SignInScreenModel sut;

    setUp(() {
      authRepository = _FakeAuthRepository();
      onLoginSuccessCallsCount = 0;
      sut = SignInScreenModel(
        authRepository: authRepository,
        onLoginSuccess: () {
          onLoginSuccessCallsCount += 1;
        },
      );
    });

    test(
      'login calls repository, clears previous error, and notifies success',
      () async {
        authRepository.result = ApiSuccess<void>(null);
        sut.errorMessage = 'previous error';

        await sut.login('user@example.com', 'strong-password');

        expect(sut.errorMessage, isNull);
        expect(authRepository.loginWithEmailCallsCount, 1);
        expect(authRepository.lastEmail, 'user@example.com');
        expect(authRepository.lastPassword, 'strong-password');
        expect(onLoginSuccessCallsCount, 1);
      },
    );

    test('login stores repository error and does not notify success', () async {
      authRepository.result = const ApiError<void>('Login failed');

      await sut.login('user@example.com', 'wrong-password');

      expect(sut.errorMessage, 'Login failed');
      expect(authRepository.loginWithEmailCallsCount, 1);
      expect(onLoginSuccessCallsCount, 0);
    });
  });
}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository()
    : super(
        authApi: _FakeAuthApi(),
        deviceIdRepository: _FakeDeviceIdRepository(),
        tokenDatabase: _FakeAuthTokensDatabase(),
      );

  ApiResult<void> result = ApiSuccess<void>(null);
  int loginWithEmailCallsCount = 0;
  String? lastEmail;
  String? lastPassword;

  @override
  Future<ApiResult<void>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    loginWithEmailCallsCount += 1;
    lastEmail = email;
    lastPassword = password;
    return result;
  }
}

class _FakeAuthApi extends AuthApi {
  @override
  Future<ApiResult<AuthTokensReponse>> loginWithEmail({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<AuthTokensReponse>> registerWithEmail({
    required String email,
    required String password,
    required String deviceId,
  }) async {
    throw UnimplementedError();
  }
}

class _FakeDeviceIdRepository implements AbstractDeviceIdRepository {
  @override
  Future<String> getDeviceId() async => 'device-id';
}

class _FakeAuthTokensDatabase implements AbstractAuthTokensDatabase {
  @override
  Future<void> saveTokens(AuthTokensEntity entity) async {}
}
