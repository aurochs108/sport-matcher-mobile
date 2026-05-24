import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/data/auth/persistence/database/auth_tokens_database.dart';

import '../../../../random/auth_tokens_entity_random.dart';
import 'auth_tokens_database_test.mocks.dart';

@GenerateMocks([FlutterSecureStorage])
void main() {
  group('AuthTokensDatabase', () {
    late MockFlutterSecureStorage storage;
    late AuthTokensDatabase sut;

    setUp(() {
      storage = MockFlutterSecureStorage();
      sut = AuthTokensDatabase(storage: storage);
    });

    test('saveTokens writes entity json under auth_tokens key', () async {
      final entity = AuthTokensEntityRandom.random();
      final expectedJson = jsonEncode(entity);
      when(
        storage.write(
          key: 'auth_tokens',
          value: expectedJson,
        ),
      ).thenAnswer((_) async {});

      await sut.saveTokens(entity);

      verify(
        storage.write(
          key: 'auth_tokens',
          value: expectedJson,
        ),
      ).called(1);
    });

    test('loadTokens returns entity when storage has token json', () async {
      final entity = AuthTokensEntityRandom.random();
      final storedJson = jsonEncode(entity);
      when(storage.read(key: 'auth_tokens')).thenAnswer((_) async => storedJson);

      final result = await sut.loadTokens();

      expect(result?.accessToken, entity.accessToken);
      expect(result?.refreshToken, entity.refreshToken);
      expect(result?.tokenType, entity.tokenType);
      expect(result?.expiresIn, entity.expiresIn);
      verify(storage.read(key: 'auth_tokens')).called(1);
    });

    test('loadTokens returns null when storage has no tokens', () async {
      when(storage.read(key: 'auth_tokens')).thenAnswer((_) async => null);

      final result = await sut.loadTokens();

      expect(result, isNull);
      verify(storage.read(key: 'auth_tokens')).called(1);
    });

    test('saveTokens propagates storage errors', () async {
      final entity = AuthTokensEntityRandom.random();
      final expectedJson = jsonEncode(entity);
      final exception = Exception('write failed');
      when(
        storage.write(
          key: 'auth_tokens',
          value: expectedJson,
        ),
      ).thenAnswer((_) => Future<void>.error(exception));

      expect(
        sut.saveTokens(entity),
        throwsA(same(exception)),
      );
    });

    test('deleteTokens deletes auth_tokens key', () async {
      when(storage.delete(key: 'auth_tokens')).thenAnswer((_) async {});

      await sut.deleteTokens();

      verify(storage.delete(key: 'auth_tokens')).called(1);
    });
  });
}
