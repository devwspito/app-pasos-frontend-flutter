import 'package:dio/dio.dart';

import '../../config/environment.dart';
import '../../utils/logger.dart';

/// Interceptor for logging HTTP requests and responses.
///
/// Only active in development mode to avoid leaking sensitive data in production.
/// Logs request details (method, URL, headers, body) and response details.
class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Environment.isDevelopment) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────');
      buffer.writeln('│ Request: ${options.method} ${options.uri}');
      buffer.writeln('├─────────────────────────────────────────────────────────');

      // Log headers (mask Authorization for security)
      if (options.headers.isNotEmpty) {
        buffer.writeln('│ Headers:');
        options.headers.forEach((key, value) {
          if (key.toLowerCase() == 'authorization') {
            buffer.writeln('│   $key: [MASKED]');
          } else {
            buffer.writeln('│   $key: $value');
          }
        });
      }

      // Log query parameters
      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ Query Parameters:');
        options.queryParameters.forEach((key, value) {
          buffer.writeln('│   $key: $value');
        });
      }

      // Log request body (truncate if too long)
      if (options.data != null) {
        buffer.writeln('│ Body:');
        final bodyString = options.data.toString();
        if (bodyString.length > 500) {
          buffer.writeln('│   ${bodyString.substring(0, 500)}...[truncated]');
        } else {
          buffer.writeln('│   $bodyString');
        }
      }

      buffer.writeln('└─────────────────────────────────────────────────────────');

      AppLogger.d(buffer.toString());
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Environment.isDevelopment) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────');
      buffer.writeln(
          '│ Response: ${response.statusCode} ${response.requestOptions.uri}');
      buffer.writeln('├─────────────────────────────────────────────────────────');

      // Log response time if available
      final requestTime = response.requestOptions.extra['requestTime'];
      if (requestTime != null) {
        final duration = DateTime.now().difference(requestTime as DateTime);
        buffer.writeln('│ Duration: ${duration.inMilliseconds}ms');
      }

      // Log response data (truncate if too long)
      if (response.data != null) {
        buffer.writeln('│ Data:');
        final dataString = response.data.toString();
        if (dataString.length > 1000) {
          buffer.writeln('│   ${dataString.substring(0, 1000)}...[truncated]');
        } else {
          buffer.writeln('│   $dataString');
        }
      }

      buffer.writeln('└─────────────────────────────────────────────────────────');

      AppLogger.d(buffer.toString());
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Environment.isDevelopment) {
      final buffer = StringBuffer();
      buffer.writeln('┌─────────────────────────────────────────────────────────');
      buffer.writeln('│ Error: ${err.type.name} ${err.requestOptions.uri}');
      buffer.writeln('├─────────────────────────────────────────────────────────');

      buffer.writeln('│ Message: ${err.message}');

      if (err.response != null) {
        buffer.writeln('│ Status Code: ${err.response?.statusCode}');
        final responseData = err.response?.data?.toString();
        if (responseData != null && responseData.isNotEmpty) {
          buffer.writeln('│ Response Data:');
          if (responseData.length > 500) {
            buffer.writeln('│   ${responseData.substring(0, 500)}...[truncated]');
          } else {
            buffer.writeln('│   $responseData');
          }
        }
      }

      buffer.writeln('└─────────────────────────────────────────────────────────');

      AppLogger.e(buffer.toString(), err, err.stackTrace);
    }

    handler.next(err);
  }
}
