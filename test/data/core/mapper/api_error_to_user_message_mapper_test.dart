import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:sport_matcher/data/core/api_request/api_exception.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';

void main() {
  group('ApiErrorToUserMessageMapper', () {
    const sut = ApiErrorToUserMessageMapper();

    final exceptionCases = <({String description, Object error, String message})>[
      (
        description: 'timeout exceptions',
        error: TimeoutException('Request timed out'),
        message: 'Request timed out. Please try again.',
      ),
      (
        description: 'generic socket exceptions',
        error: const SocketException('No internet'),
        message: 'No internet connection. Please check your network.',
      ),
      (
        description: 'connection refused socket exceptions',
        error: const SocketException(
          'Connection refused',
          osError: OSError('Connection refused', 61),
        ),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'connection refused socket exceptions on Linux',
        error: const SocketException(
          'Connection refused',
          osError: OSError('Connection refused', 111),
        ),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'connection refused socket exceptions on Windows',
        error: const SocketException(
          'Connection refused',
          osError: OSError('Connection refused', 10061),
        ),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'connection refused socket exceptions by message',
        error: const SocketException('Connection refused'),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'TLS exceptions',
        error: TlsException('TLS failed'),
        message: 'Secure connection to the server failed. Please try again.',
      ),
      (
        description: 'HTTP client exceptions',
        error: http.ClientException('Client failed'),
        message: 'A network error occurred. Please try again.',
      ),
      (
        description: 'connection refused HTTP client exceptions',
        error: http.ClientException('Connection refused'),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'connection refused HTTP client exceptions ignoring case',
        error: http.ClientException('Connection refused'),
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        description: 'HTTP exceptions',
        error: const HttpException('HTTP failed'),
        message: 'A network error occurred. Please try again.',
      ),
      (
        description: 'unsupported API status codes',
        error: ApiException(statusCode: 418),
        message: 'Something went wrong. Please try again.',
      ),
      (
        description: 'unexpected errors',
        error: StateError('Unexpected failure'),
        message: 'Something went wrong. Please try again.',
      ),
    ];

    for (final testCase in exceptionCases) {
      test('map returns expected message for ${testCase.description}', () {
        final result = sut.map(testCase.error);

        expect(result, testCase.message);
      });
    }

    final apiStatusCases = <({int statusCode, String message})>[
      (
        statusCode: 400,
        message: 'Invalid request. Please check your input.',
      ),
      (
        statusCode: 401,
        message: 'Unauthorized. Please sign in again.',
      ),
      (
        statusCode: 403,
        message: 'You don\'t have permission to perform this action.',
      ),
      (
        statusCode: 404,
        message: 'The requested resource was not found.',
      ),
      (
        statusCode: 408,
        message: 'Request timed out. Please try again.',
      ),
      (
        statusCode: 409,
        message: 'A conflict occurred. Please try again.',
      ),
      (
        statusCode: 422,
        message: 'Invalid data. Please check your input.',
      ),
      (
        statusCode: 429,
        message: 'Too many requests. Please try again later.',
      ),
      (
        statusCode: 500,
        message: 'Something went wrong on our end. Please try again later.',
      ),
      (
        statusCode: 502,
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        statusCode: 503,
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
      (
        statusCode: 504,
        message: 'Server is temporarily unavailable. Please try again later.',
      ),
    ];

    for (final testCase in apiStatusCases) {
      test(
        'map returns expected message for API status ${testCase.statusCode}',
        () {
          final result = sut.map(ApiException(statusCode: testCase.statusCode));

          expect(result, testCase.message);
        },
      );
    }
  });
}
