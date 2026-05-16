import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:sport_matcher/data/core/api_request/api_exception.dart';

class ApiErrorToUserMessageMapper {
  static const _genericErrorMessage = 'Something went wrong. Please try again.';
  static const _serverUnavailableMessage =
      'Server is temporarily unavailable. Please try again later.';
  static const _timeoutMessage = 'Request timed out. Please try again.';
  static const _connectionRefusedErrorCodes = {
    61,
    111,
    10061,
  };

  static const _httpStatusMessages = {
    400: 'Invalid request. Please check your input.',
    401: 'Unauthorized. Please sign in again.',
    403: 'You don\'t have permission to perform this action.',
    404: 'The requested resource was not found.',
    408: _timeoutMessage,
    409: 'A conflict occurred. Please try again.',
    422: 'Invalid data. Please check your input.',
    429: 'Too many requests. Please try again later.',
    500: 'Something went wrong on our end. Please try again later.',
    502: _serverUnavailableMessage,
    503: _serverUnavailableMessage,
    504: _serverUnavailableMessage,
  };

  const ApiErrorToUserMessageMapper();

  String map(Object error) {
    if (error is TimeoutException) {
      return _timeoutMessage;
    }

    if (error is SocketException && _isConnectionRefused(error)) {
      return _serverUnavailableMessage;
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is TlsException) {
      return 'Secure connection to the server failed. Please try again.';
    }

    if (error is http.ClientException &&
        _isConnectionRefusedMessage(error.message)) {
      return _serverUnavailableMessage;
    }

    if (error is http.ClientException || error is HttpException) {
      return 'A network error occurred. Please try again.';
    }

    if (error is ApiException) {
      return _httpStatusMessages[error.statusCode] ?? _genericErrorMessage;
    }

    return _genericErrorMessage;
  }

  bool _isConnectionRefused(SocketException error) {
    final errorCode = error.osError?.errorCode;
    if (errorCode != null &&
        _connectionRefusedErrorCodes.contains(errorCode)) {
      return true;
    }

    return _isConnectionRefusedMessage(error.message);
  }

  bool _isConnectionRefusedMessage(String message) {
    return message.toLowerCase().contains('connection refused');
  }
}
