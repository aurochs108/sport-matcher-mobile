import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';

abstract class AbstractAuthTokensDatabase {
  Future<AuthTokensEntity?> loadTokens();

  Future<void> saveTokens(AuthTokensEntity entity);

  Future<void> deleteTokens();
}
