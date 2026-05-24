import 'dart:math';

import 'package:sport_matcher/data/auth/persistence/entity/auth_tokens_entity.dart';
import 'package:uuid/uuid.dart';

class AuthTokensEntityRandom {
  static AuthTokensEntity random() {
    final random = Random();

    return AuthTokensEntity(
      accessToken: const Uuid().v4(),
      refreshToken: const Uuid().v4(),
      tokenType: _randomTokenType(random),
      expiresIn: random.nextInt(86400) + 1,
      accessTokenExpiresAtMillisecondsSinceEpoch:
          DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch,
    );
  }

  static String _randomTokenType(Random random) {
    return ['Bearer', 'Token'][random.nextInt(2)];
  }
}
