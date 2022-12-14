import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'exceptions.dart';

class WebClientQueuedInterceptorsWrapper extends QueuedInterceptorsWrapper {
  WebClientQueuedInterceptorsWrapper({
    InterceptorSendCallback? onRequest,
    InterceptorSuccessCallback? onResponse,
    InterceptorErrorCallback? onError,
  }) : super(
          onError: onError,
          onRequest: onRequest,
          onResponse: onResponse,
        );
}

abstract class WebClient extends Interceptor with EquatableMixin {
  final Dio dio;
  final String? accessToken;

  WebClient({
    required this.dio,
    this.accessToken,
  }) {
    dio.interceptors.removeWhere((element) => element is WebClient);
    dio.interceptors.add(this);
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey('Authorization') &&
        accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    final endpoint = err.requestOptions.uri.toString();
    final statusCode = err.response?.statusCode;
    if (statusCode == 403) {
      debugPrint("AccessDeniedException: $endpoint");
    } else if (statusCode == 401) {
      debugPrint("UnauthorizedException: $endpoint");
    } else if (statusCode == 404) {
      debugPrint("NotFoundException: $endpoint");
    } else if (statusCode == 500) {
      debugPrint("ServerException: $endpoint");
    }
    super.onError(err, handler);
  }

  @override
  List<Object?> get props => [dio, accessToken];

  @override
  String toString() => 'WebClient {baseUrl:${dio.options.baseUrl}';
}
