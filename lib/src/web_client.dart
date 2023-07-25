// ignore_for_file: unused_import

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;

class WebClientQueuedInterceptorsWrapper extends QueuedInterceptorsWrapper {
  WebClientQueuedInterceptorsWrapper({
    super.onRequest,
    super.onResponse,
    super.onError,
  });
}

abstract class WebClient extends Interceptor with EquatableMixin {
  WebClient({
    required this.dio,
    String? accessToken,
  }) : _accessToken = accessToken {
    dio.interceptors.removeWhere((element) => element is WebClient);
    dio.interceptors.add(this);
  }
  final Dio dio;
  Future<String?> get accessToken async => _accessToken;
  final String? _accessToken;
  String? get accessTokenValue => _accessToken;

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!options.headers.containsKey('Authorization')) {
      final token = await accessToken;
      if (token?.isNotEmpty == true) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final endpoint = err.requestOptions.uri.toString();
    final statusCode = err.response?.statusCode;
    if (statusCode == 403) {
      debugPrint('AccessDeniedException: $endpoint');
    } else if (statusCode == 401) {
      debugPrint('UnauthorizedException: $endpoint');
    } else if (statusCode == 404) {
      debugPrint('NotFoundException: $endpoint');
    } else if (statusCode == 500) {
      debugPrint('ServerException: $endpoint');
    }
    super.onError(err, handler);
  }

  @override
  List<Object?> get props => [dio, accessTokenValue];

  @override
  String toString() => 'WebClient {baseUrl:${dio.options.baseUrl}';
}
