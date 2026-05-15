import 'package:sport_matcher/data/auth/network/response/auth_tokens_reponse.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';

abstract class AbstractAuthApi {
  Future<ApiResult<AuthTokensReponse>> loginWithEmail({
    required String email,
    required String password,
    required String deviceId,
  });

  Future<ApiResult<AuthTokensReponse>> registerWithEmail({
    required String email,
    required String password,
    required String deviceId,
  });
}
