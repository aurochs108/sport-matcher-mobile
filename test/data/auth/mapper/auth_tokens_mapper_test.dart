import 'package:flutter_test/flutter_test.dart';
import 'package:sport_matcher/data/auth/mapper/auth_tokens_mapper.dart';

import '../../../random/auth_tokens_domain_random.dart';
import '../../../random/auth_tokens_response_random.dart';

void main() {
  group('AuthTokensMapper', () {
    final now = DateTime(2026, 1, 1, 12);
    late AuthTokensMapper sut;

    setUp(() {
      sut = AuthTokensMapper(now: () => now);
    });

    test('responseToDomain maps response fields to domain', () {
      final response = AuthTokensResponseRandom.random();

      final result = sut.responseToDomain(response);

      expect(result.accessToken, response.accessToken);
      expect(result.refreshToken, response.refreshToken);
      expect(result.tokenType, response.tokenType);
      expect(result.expiresIn, response.expiresIn);
    });

    test('domainToEntity maps domain fields to entity', () {
      final domain = AuthTokensDomainRandom.random();

      final result = sut.domainToEntity(domain);

      expect(result.accessToken, domain.accessToken);
      expect(result.refreshToken, domain.refreshToken);
      expect(result.tokenType, domain.tokenType);
      expect(result.expiresIn, domain.expiresIn);
      expect(
        result.accessTokenExpiresAtMillisecondsSinceEpoch,
        now.add(Duration(seconds: domain.expiresIn)).millisecondsSinceEpoch,
      );
    });
  });
}
