import 'package:sport_matcher/data/auth/domain/auth_tokens.dart';
import 'package:sport_matcher/data/auth/network/response/auth_tokens_reponse.dart';
import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';

class AuthTokensMapper {
  final DateTime Function() _now;

  AuthTokensMapper({DateTime Function()? now}) : _now = now ?? DateTime.now;

  AuthTokensDomain responseToDomain(AuthTokensReponse response) {
    return AuthTokensDomain(
      accessToken: response.accessToken,
      refreshToken: response.refreshToken,
      tokenType: response.tokenType,
      expiresIn: response.expiresIn,
    );
  }

  AuthTokensEntity domainToEntity(AuthTokensDomain domain) {
    return AuthTokensEntity(
      accessToken: domain.accessToken,
      refreshToken: domain.refreshToken,
      tokenType: domain.tokenType,
      expiresIn: domain.expiresIn,
      accessTokenExpiresAtMillisecondsSinceEpoch:
          _now().add(Duration(seconds: domain.expiresIn))
              .millisecondsSinceEpoch,
    );
  }
}
