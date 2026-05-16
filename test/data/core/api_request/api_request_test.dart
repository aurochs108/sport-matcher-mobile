import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sport_matcher/config/api_config.dart';
import 'package:sport_matcher/data/core/api_request/api_exception.dart';
import 'package:sport_matcher/data/core/api_request/api_request.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/api_request/http_method.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';

import 'api_request_test.mocks.dart';

@GenerateMocks([ApiErrorToUserMessageMapper])
void main() {
  group('ApiRequest', () {
    for (final responseStatusCode in [200, 299]) {
      test(
        'execute sends POST request and returns parsed success for $responseStatusCode',
        () async {
          late http.Request capturedRequest;
          final client = MockClient((request) async {
            capturedRequest = request;
            return http.Response(
              jsonEncode({'value': 'parsed value'}),
              responseStatusCode,
            );
          });
          final sut = ApiRequest<String>(
            path: '/test-path',
            method: HttpMethod.post,
            body: {'email': 'test@example.com'},
            responseParser: (json) => json['value'] as String,
            client: client,
          );

          final result = await sut.execute();

          expect(capturedRequest.method, 'POST');
          expect(
            capturedRequest.url.toString(),
            '${ApiConfig.baseUrl}/test-path',
          );
          expect(capturedRequest.headers['Content-Type'], 'application/json');
          expect(
            capturedRequest.body,
            jsonEncode({'email': 'test@example.com'}),
          );
          expect(result, isA<ApiSuccess<String>>());
          expect((result as ApiSuccess<String>).data, 'parsed value');
        },
      );
    }

    test(
      'execute returns mapped error with status code when success body cannot be parsed',
      () async {
        final errorMapper = MockApiErrorToUserMessageMapper();
        final client = MockClient((request) async {
          return http.Response('not-json', 200);
        });
        when(errorMapper.map(any)).thenReturn('mapped error');
        final sut = ApiRequest<String>(
          path: '/test-path',
          method: HttpMethod.post,
          responseParser: (json) => json['value'] as String,
          client: client,
          errorMapper: errorMapper,
        );

        final result = await sut.execute();

        expect(result, isA<ApiError<String>>());
        expect((result as ApiError<String>).message, 'mapped error');
        expect(result.statusCode, 200);
        verify(errorMapper.map(argThat(isA<FormatException>()))).called(1);
      },
    );

    test(
      'execute returns mapped error with status code and code for parsed error response',
      () async {
        final errorMapper = MockApiErrorToUserMessageMapper();
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({'code': 'EMAIL_ALREADY_REGISTERED'}),
            409,
          );
        });
        when(errorMapper.map(any)).thenReturn('mapped error');
        final sut = ApiRequest<String>(
          path: '/test-path',
          method: HttpMethod.post,
          responseParser: (json) => json['value'] as String,
          client: client,
          errorMapper: errorMapper,
        );

        final result = await sut.execute();

        expect(result, isA<ApiError<String>>());
        expect((result as ApiError<String>).message, 'mapped error');
        expect(result.statusCode, 409);
        expect(result.code, 'EMAIL_ALREADY_REGISTERED');
        final capturedError =
            verify(errorMapper.map(captureAny)).captured.single as ApiException;
        expect(capturedError.statusCode, 409);
        expect(capturedError.errorResponse?.code, 'EMAIL_ALREADY_REGISTERED');
      },
    );

    test(
      'execute returns mapped error with status code when error response cannot be parsed',
      () async {
        final errorMapper = MockApiErrorToUserMessageMapper();
        final client = MockClient((request) async {
          return http.Response('not-json', 500);
        });
        when(errorMapper.map(any)).thenReturn('mapped error');
        final sut = ApiRequest<String>(
          path: '/test-path',
          method: HttpMethod.post,
          responseParser: (json) => json['value'] as String,
          client: client,
          errorMapper: errorMapper,
        );

        final result = await sut.execute();

        expect(result, isA<ApiError<String>>());
        expect((result as ApiError<String>).message, 'mapped error');
        expect(result.statusCode, 500);
        expect(result.code, isNull);
        final capturedError =
            verify(errorMapper.map(captureAny)).captured.single as ApiException;
        expect(capturedError.statusCode, 500);
        expect(capturedError.errorResponse, isNull);
      },
    );

    test('execute returns mapped error when client throws', () async {
      final errorMapper = MockApiErrorToUserMessageMapper();
      final exception = http.ClientException('network failed');
      final client = MockClient((request) async {
        throw exception;
      });
      when(errorMapper.map(any)).thenReturn('mapped error');
      final sut = ApiRequest<String>(
        path: '/test-path',
        method: HttpMethod.post,
        responseParser: (json) => json['value'] as String,
        client: client,
        errorMapper: errorMapper,
      );

      final result = await sut.execute();

      expect(result, isA<ApiError<String>>());
      expect((result as ApiError<String>).message, 'mapped error');
      expect(result.statusCode, isNull);
      verify(errorMapper.map(same(exception))).called(1);
    });
  });
}
