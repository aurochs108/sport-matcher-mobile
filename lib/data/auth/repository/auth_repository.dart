import 'package:sport_matcher/data/auth/mapper/auth_tokens_mapper.dart';
import 'package:sport_matcher/data/auth/network/api/auth_api.dart';
import 'package:sport_matcher/data/auth/persistence/database/abstract_auth_tokens_database.dart';
import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';
import 'package:sport_matcher/data/device_id/repository/abstract_device_id_repository.dart';
import 'package:sport_matcher/data/device_id/repository/device_id_repository.dart';

class AuthRepository {
  final AuthApi _authApi;
  final AbstractDeviceIdRepository _deviceIdRepository;
  final AbstractAuthTokensDatabase _tokenDatabase;
  final AuthTokensMapper _mapper;
  final ApiErrorToUserMessageMapper _errorMapper;

  AuthRepository({
    AuthApi? authApi,
    AbstractDeviceIdRepository? deviceIdRepository,
    AbstractAuthTokensDatabase? tokenDatabase,
    AuthTokensMapper? mapper,
    ApiErrorToUserMessageMapper? errorMapper,
  }) : _authApi = authApi ?? AuthApi(),
       _deviceIdRepository = deviceIdRepository ?? DeviceIdRepository(),
       _tokenDatabase = tokenDatabase ?? AuthTokensDatabase(),
       _mapper = mapper ?? AuthTokensMapper(),
       _errorMapper = errorMapper ?? const ApiErrorToUserMessageMapper();

  Future<ApiResult<void>> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _deviceIdRepository.getDeviceId();
      final result = await _authApi.loginWithEmail(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      switch (result) {
        case ApiSuccess(:final data):
          final tokens = _mapper.responseToDomain(data);
          await _tokenDatabase.saveTokens(_mapper.domainToEntity(tokens));
          return ApiSuccess<void>(null);
        case ApiError():
          return _mapError(result);
      }
    } catch (error) {
      return ApiError<void>(_errorMapper.map(error));
    }
  }

  Future<ApiResult<void>> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final deviceId = await _deviceIdRepository.getDeviceId();
      final result = await _authApi.registerWithEmail(
        email: email,
        password: password,
        deviceId: deviceId,
      );

      switch (result) {
        case ApiSuccess(:final data):
          final tokens = _mapper.responseToDomain(data);
          await _tokenDatabase.saveTokens(_mapper.domainToEntity(tokens));
          return ApiSuccess<void>(null);
        case ApiError():
          return _mapError(result);
      }
    } catch (error) {
      return ApiError<void>(_errorMapper.map(error));
    }
  }

  ApiError<void> _mapError<T>(ApiError<T> error) {
    return ApiError<void>(
      error.message,
      statusCode: error.statusCode,
      code: error.code,
    );
  }
}
