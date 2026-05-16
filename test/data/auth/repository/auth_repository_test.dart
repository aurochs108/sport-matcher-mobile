import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/mapper/auth_tokens_mapper.dart';
import 'package:sport_matcher/data/auth/network/api/auth_api.dart';
import 'package:sport_matcher/data/auth/network/response/auth_tokens_reponse.dart';
import 'package:sport_matcher/data/auth/persistence/database/abstract_auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/repository/auth_repository.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';
import 'package:sport_matcher/data/device_id/repository/abstract_device_id_repository.dart';
import 'package:uuid/uuid.dart';

import '../../../random/auth_tokens_domain_random.dart';
import '../../../random/auth_tokens_entity_random.dart';
import '../../../random/auth_tokens_response_random.dart';
import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  AuthApi,
  AbstractDeviceIdRepository,
  AbstractAuthTokensDatabase,
  AuthTokensMapper,
  ApiErrorToUserMessageMapper,
])
void main() {
  provideDummy<ApiResult<AuthTokensReponse>>(
    const ApiError<AuthTokensReponse>('dummy error'),
  );

  group('AuthRepository', () {
    late MockAuthApi authApi;
    late MockAbstractDeviceIdRepository deviceIdRepository;
    late MockAbstractAuthTokensDatabase tokenDatabase;
    late MockAuthTokensMapper mapper;
    late MockApiErrorToUserMessageMapper errorMapper;
    late AuthRepository sut;

    setUp(() {
      authApi = MockAuthApi();
      deviceIdRepository = MockAbstractDeviceIdRepository();
      tokenDatabase = MockAbstractAuthTokensDatabase();
      mapper = MockAuthTokensMapper();
      errorMapper = MockApiErrorToUserMessageMapper();
      sut = AuthRepository(
        authApi: authApi,
        deviceIdRepository: deviceIdRepository,
        tokenDatabase: tokenDatabase,
        mapper: mapper,
        errorMapper: errorMapper,
      );
    });

    test(
      'loginWithEmail gets device ID, calls API, saves tokens, and returns success',
      () async {
        final response = AuthTokensResponseRandom.random();
        final mappedTokens = AuthTokensDomainRandom.random();
        final mappedEntity = AuthTokensEntityRandom.random();
        final deviceId = Uuid().v4();

        when(
          deviceIdRepository.getDeviceId(),
        ).thenAnswer((_) async => deviceId);

        final email = 'user@example.com';
        final password = Uuid().v4();
        when(
          authApi.loginWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).thenAnswer((_) async => ApiSuccess(response));
        when(mapper.responseToDomain(response)).thenReturn(mappedTokens);
        when(mapper.domainToEntity(mappedTokens)).thenReturn(mappedEntity);
        when(tokenDatabase.saveTokens(mappedEntity)).thenAnswer((_) async {});

        final result = await sut.loginWithEmail(
          email: email,
          password: password,
        );

        expect(result, isA<ApiSuccess<void>>());
        verify(deviceIdRepository.getDeviceId()).called(1);
        verify(
          authApi.loginWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).called(1);
        verify(mapper.responseToDomain(response)).called(1);
        verify(mapper.domainToEntity(mappedTokens)).called(1);
        verify(tokenDatabase.saveTokens(mappedEntity)).called(1);
        verifyZeroInteractions(errorMapper);
      },
    );

    test('loginWithEmail returns API error without saving tokens', () async {
      const email = 'user@example.com';
      const password = 'strong-password';
      const deviceId = 'device-id';
      const errorMessage = 'Login failed';
      const statusCode = 401;
      const errorCode = 'INVALID_CREDENTIALS';

      when(
        deviceIdRepository.getDeviceId(),
      ).thenAnswer((_) async => deviceId);
      when(
        authApi.loginWithEmail(
          email: email,
          password: password,
          deviceId: deviceId,
        ),
      ).thenAnswer(
        (_) async => const ApiError<AuthTokensReponse>(
          errorMessage,
          statusCode: statusCode,
          code: errorCode,
        ),
      );

      final result = await sut.loginWithEmail(
        email: email,
        password: password,
      );

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError<void>).message, errorMessage);
      expect(result.statusCode, statusCode);
      expect(result.code, errorCode);
      verify(deviceIdRepository.getDeviceId()).called(1);
      verify(
        authApi.loginWithEmail(
          email: email,
          password: password,
          deviceId: deviceId,
        ),
      ).called(1);
      verifyZeroInteractions(mapper);
      verifyZeroInteractions(tokenDatabase);
      verifyZeroInteractions(errorMapper);
    });

    test('loginWithEmail maps device ID errors to ApiError', () async {
      const email = 'user@example.com';
      const password = 'strong-password';
      final exception = Exception('device id failed');
      const mappedErrorMessage = 'mapped error';

      when(
        deviceIdRepository.getDeviceId(),
      ).thenAnswer((_) => Future<String>.error(exception));
      when(errorMapper.map(exception)).thenReturn(mappedErrorMessage);

      final result = await sut.loginWithEmail(
        email: email,
        password: password,
      );

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError<void>).message, mappedErrorMessage);
      expect(result.statusCode, isNull);
      expect(result.code, isNull);
      verify(errorMapper.map(same(exception))).called(1);
      verifyZeroInteractions(authApi);
      verifyZeroInteractions(tokenDatabase);
    });

    test(
      'loginWithEmail maps token persistence errors to ApiError',
      () async {
        const email = 'user@example.com';
        const password = 'strong-password';
        const deviceId = 'device-id';
        final response = AuthTokensResponseRandom.random();
        final mappedTokens = AuthTokensDomainRandom.random();
        final mappedEntity = AuthTokensEntityRandom.random();
        final exception = Exception('save failed');
        const mappedErrorMessage = 'mapped error';

        when(
          deviceIdRepository.getDeviceId(),
        ).thenAnswer((_) async => deviceId);
        when(
          authApi.loginWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).thenAnswer((_) async => ApiSuccess(response));
        when(mapper.responseToDomain(response)).thenReturn(mappedTokens);
        when(mapper.domainToEntity(mappedTokens)).thenReturn(mappedEntity);
        when(
          tokenDatabase.saveTokens(mappedEntity),
        ).thenAnswer((_) => Future<void>.error(exception));
        when(errorMapper.map(exception)).thenReturn(mappedErrorMessage);

        final result = await sut.loginWithEmail(
          email: email,
          password: password,
        );

        expect(result, isA<ApiError<void>>());
        expect((result as ApiError<void>).message, mappedErrorMessage);
        expect(result.statusCode, isNull);
        expect(result.code, isNull);
        verify(errorMapper.map(same(exception))).called(1);
      },
    );

    test(
      'registerWithEmail gets device ID, calls API, saves tokens, and returns success',
      () async {
        final response = AuthTokensResponseRandom.random();
        final mappedTokens = AuthTokensDomainRandom.random();
        final mappedEntity = AuthTokensEntityRandom.random();
        final deviceId = Uuid().v4();

        when(
          deviceIdRepository.getDeviceId(),
        ).thenAnswer((_) async => deviceId);

        final email = 'user@example.com';
        final password = Uuid().v4();
        when(
          authApi.registerWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).thenAnswer((_) async => ApiSuccess(response));
        when(mapper.responseToDomain(response)).thenReturn(mappedTokens);
        when(mapper.domainToEntity(mappedTokens)).thenReturn(mappedEntity);
        when(tokenDatabase.saveTokens(mappedEntity)).thenAnswer((_) async {});

        final result = await sut.registerWithEmail(
          email: email,
          password: password,
        );

        expect(result, isA<ApiSuccess<void>>());
        verify(deviceIdRepository.getDeviceId()).called(1);
        verify(
          authApi.registerWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).called(1);
        verify(mapper.responseToDomain(response)).called(1);
        verify(mapper.domainToEntity(mappedTokens)).called(1);
        verify(tokenDatabase.saveTokens(mappedEntity)).called(1);
        verifyZeroInteractions(errorMapper);
      },
    );

    test('registerWithEmail returns API error without saving tokens', () async {
      const email = 'user@example.com';
      const password = 'strong-password';
      const deviceId = 'device-id';
      const errorMessage = 'Registration failed';
      const statusCode = 409;
      const errorCode = 'EMAIL_ALREADY_REGISTERED';

      when(
        deviceIdRepository.getDeviceId(),
      ).thenAnswer((_) async => deviceId);
      when(
        authApi.registerWithEmail(
          email: email,
          password: password,
          deviceId: deviceId,
        ),
      ).thenAnswer(
        (_) async => const ApiError<AuthTokensReponse>(
          errorMessage,
          statusCode: statusCode,
          code: errorCode,
        ),
      );

      final result = await sut.registerWithEmail(
        email: email,
        password: password,
      );

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError<void>).message, errorMessage);
      expect(result.statusCode, statusCode);
      expect(result.code, errorCode);
      verify(deviceIdRepository.getDeviceId()).called(1);
      verify(
        authApi.registerWithEmail(
          email: email,
          password: password,
          deviceId: deviceId,
        ),
      ).called(1);
      verifyZeroInteractions(mapper);
      verifyZeroInteractions(tokenDatabase);
      verifyZeroInteractions(errorMapper);
    });

    test('registerWithEmail maps device ID errors to ApiError', () async {
      const email = 'user@example.com';
      const password = 'strong-password';
      final exception = Exception('device id failed');
      const mappedErrorMessage = 'mapped error';

      when(
        deviceIdRepository.getDeviceId(),
      ).thenAnswer((_) => Future<String>.error(exception));
      when(errorMapper.map(exception)).thenReturn(mappedErrorMessage);

      final result = await sut.registerWithEmail(
        email: email,
        password: password,
      );

      expect(result, isA<ApiError<void>>());
      expect((result as ApiError<void>).message, mappedErrorMessage);
      expect(result.statusCode, isNull);
      expect(result.code, isNull);
      verify(errorMapper.map(same(exception))).called(1);
      verifyZeroInteractions(authApi);
      verifyZeroInteractions(tokenDatabase);
    });

    test(
      'registerWithEmail maps token persistence errors to ApiError',
      () async {
        const email = 'user@example.com';
        const password = 'strong-password';
        const deviceId = 'device-id';
        final response = AuthTokensResponseRandom.random();
        final mappedTokens = AuthTokensDomainRandom.random();
        final mappedEntity = AuthTokensEntityRandom.random();
        final exception = Exception('save failed');
        const mappedErrorMessage = 'mapped error';

        when(
          deviceIdRepository.getDeviceId(),
        ).thenAnswer((_) async => deviceId);
        when(
          authApi.registerWithEmail(
            email: email,
            password: password,
            deviceId: deviceId,
          ),
        ).thenAnswer((_) async => ApiSuccess(response));
        when(mapper.responseToDomain(response)).thenReturn(mappedTokens);
        when(mapper.domainToEntity(mappedTokens)).thenReturn(mappedEntity);
        when(
          tokenDatabase.saveTokens(mappedEntity),
        ).thenAnswer((_) => Future<void>.error(exception));
        when(errorMapper.map(exception)).thenReturn(mappedErrorMessage);

        final result = await sut.registerWithEmail(
          email: email,
          password: password,
        );

        expect(result, isA<ApiError<void>>());
        expect((result as ApiError<void>).message, mappedErrorMessage);
        expect(result.statusCode, isNull);
        expect(result.code, isNull);
        verify(errorMapper.map(same(exception))).called(1);
      },
    );
  });
}
