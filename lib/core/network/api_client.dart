import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/app_constants.dart';

/// Custom exceptions thrown by the remote data source and translated
/// into [Failure]s by the repository layer. Each one maps to exactly
/// one root cause so the UI never has to guess why a request failed.
class ServerException implements Exception {
  final String message;
  ServerException([this.message = 'Server error']);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException([this.message = 'Not found']);
}

class NetworkException implements Exception {
  final String message;
  NetworkException([this.message = 'No internet connection']);
}

/// 401 / 403 — the API key is missing, malformed, or rejected by OpenWeatherMap.
class ApiKeyException implements Exception {
  final String message;
  ApiKeyException([this.message = 'Invalid or missing API key']);
}

/// 429 — too many requests for the current plan / time window.
class RateLimitException implements Exception {
  final String message;
  RateLimitException([this.message = 'Rate limit exceeded']);
}

/// Thin wrapper around [Dio] configured for the OpenWeatherMap API.
///
/// Every request and response is logged via the internal [_log] so
/// failures are diagnosable from the console instead of surfacing only
/// as a vague "Unknown error occurred" in the UI.
class ApiClient {
  late final Dio dio;
  final Logger _log = Logger(printer: PrettyPrinter(methodCount: 0));

  ApiClient() {
    dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(milliseconds: AppConstants.connectTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        queryParameters: {
          'appid': AppConstants.apiKey,
          'units': 'metric',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _log.i(
            'REQUEST -> ${options.method} ${options.baseUrl}${options.path}\n'
            'params: ${_redactApiKey(options.queryParameters)}',
          );
          handler.next(options);
        },
        onResponse: (response, handler) {
          _log.i(
            'RESPONSE <- ${response.requestOptions.path} '
            '[${response.statusCode}]\n'
            'body: ${_truncate(response.data)}',
          );
          handler.next(response);
        },
        onError: (DioException e, handler) {
          _log.e(
            'ERROR <- ${e.requestOptions.path} '
            '[${e.response?.statusCode ?? 'no status'}]\n'
            'type: ${e.type}\n'
            'body: ${_truncate(e.response?.data)}',
            error: e,
            stackTrace: e.stackTrace,
          );
          handler.next(e);
        },
      ),
    );
  }

  Map<String, dynamic> _redactApiKey(Map<String, dynamic> params) {
    final copy = Map<String, dynamic>.from(params);
    if (copy.containsKey('appid')) copy['appid'] = '****';
    return copy;
  }

  String _truncate(dynamic body) {
    final s = body?.toString() ?? 'null';
    return s.length > 500 ? '${s.substring(0, 500)}...' : s;
  }

  /// Extracts OpenWeatherMap's own {"cod":401,"message":"..."} error body
  /// when present, so the real reason reaches the user instead of a generic
  /// Dio message (which is frequently null for HTTP error responses).
  String _apiErrorMessage(DioException e, String fallback) {
    final data = e.response?.data;
    if (data is Map && data['message'] is String) {
      return data['message'] as String;
    }
    return fallback;
  }

  Never _throwMappedException(DioException e) {
    if (!AppConstants.isApiKeyConfigured) {
      throw ApiKeyException(
        'No API key configured. Set AppConstants.apiKey in '
        'lib/core/constants/app_constants.dart.',
      );
    }

    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      throw NetworkException();
    }

    final status = e.response?.statusCode;
    switch (status) {
      case 401:
      case 403:
        throw ApiKeyException(
          _apiErrorMessage(e, 'Invalid API key. Check AppConstants.apiKey.'),
        );
      case 404:
        throw NotFoundException(_apiErrorMessage(e, 'Location not found.'));
      case 429:
        throw RateLimitException(
          _apiErrorMessage(e, 'Rate limit exceeded. Try again shortly.'),
        );
      default:
        if (status != null && status >= 500) {
          throw ServerException(
            _apiErrorMessage(e, 'Weather service is temporarily unavailable.'),
          );
        }
        throw ServerException(_apiErrorMessage(e, e.message ?? 'Server error'));
    }
  }

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!AppConstants.isApiKeyConfigured) {
        _log.w('BLOCKED REQUEST -> $url : API key is not configured.');
        throw ApiKeyException(
          'No API key configured. Set AppConstants.apiKey in '
          'lib/core/constants/app_constants.dart.',
        );
      }
      final response = await dio.get(url, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      _throwMappedException(e);
    } catch (e, st) {
      _log.e('UNEXPECTED ERROR -> $url', error: e, stackTrace: st);
      throw ServerException();
    }
  }

  Future<List<dynamic>> getList(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      if (!AppConstants.isApiKeyConfigured) {
        _log.w('BLOCKED REQUEST -> $url : API key is not configured.');
        throw ApiKeyException(
          'No API key configured. Set AppConstants.apiKey in '
          'lib/core/constants/app_constants.dart.',
        );
      }
      final response = await dio.get(url, queryParameters: queryParameters);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      _throwMappedException(e);
    } catch (e, st) {
      _log.e('UNEXPECTED ERROR -> $url', error: e, stackTrace: st);
      throw ServerException();
    }
  }
}
