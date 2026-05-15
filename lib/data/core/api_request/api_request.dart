import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;
import 'package:sport_matcher/config/api_config.dart';
import 'package:sport_matcher/data/core/api_request/api_exception.dart';
import 'package:sport_matcher/data/core/api_request/api_result.dart';
import 'package:sport_matcher/data/core/api_request/error_response.dart';
import 'package:sport_matcher/data/core/api_request/http_client_provider.dart';
import 'package:sport_matcher/data/core/api_request/http_method.dart';
import 'package:sport_matcher/data/core/mapper/api_error_to_user_message_mapper.dart';

class ApiRequest<T> {
  final String path;
  final HttpMethod method;
  final Map<String, dynamic>? body;
  final T Function(Map<String, dynamic>) responseParser;
  final Duration timeout;
  final http.Client _client;
  final ApiErrorToUserMessageMapper _errorMapper;

  ApiRequest({
    required this.path,
    required this.method,
    required this.responseParser,
    this.body,
    this.timeout = const Duration(seconds: 30),
    http.Client? client,
    ApiErrorToUserMessageMapper? errorMapper,
  })  : _client = client ?? HttpClientProvider.instance,
        _errorMapper = errorMapper ?? const ApiErrorToUserMessageMapper();

  Future<ApiResult<T>> execute() async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}$path');
      final headers = {
        'Content-Type': 'application/json',
      };
      final response = await switch (method) {
        HttpMethod.post => _client.post(
            url,
            headers: headers,
            body: body != null ? jsonEncode(body) : null,
          ),
      }.timeout(timeout);

      if (kDebugMode) {
        debugPrint('ApiRequest [$path] ${response.statusCode}: ${response.body}');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return _parseSuccess(response);
      }
      return _parseError(response);
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('ApiRequest error: $error');
        debugPrint('StackTrace: $stackTrace');
      }
      return ApiError(_errorMapper.map(error));
    }
  }

  ApiResult<T> _parseSuccess(http.Response response) {
    try {
      return ApiSuccess(responseParser(jsonDecode(response.body)));
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('ApiRequest deserialization error: $error');
        debugPrint('StackTrace: $stackTrace');
      }
      return ApiError(_errorMapper.map(error), statusCode: response.statusCode);
    }
  }

  ApiResult<T> _parseError(http.Response response) {
    try {
      final errorResponse = ErrorResponse.fromJson(jsonDecode(response.body));
      return ApiError(
        _errorMapper.map(ApiException(
          statusCode: response.statusCode,
          errorResponse: errorResponse,
        )),
        statusCode: response.statusCode,
        code: errorResponse.code,
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('ApiRequest error response parsing error: $error');
      }
      return ApiError(
        _errorMapper.map(ApiException(statusCode: response.statusCode)),
        statusCode: response.statusCode,
      );
    }
  }
}
