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

abstract class WebClient extends Equatable implements Interceptor {
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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _throwIfNotSuccess(response.statusCode,
        endpoint: response.requestOptions.uri.toString());
    handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    _throwIfNotSuccess(err.response?.statusCode,
        endpoint: err.requestOptions.uri.toString());
    handler.next(err);
  }

  @override
  List<Object?> get props => [dio, accessToken];

  @override
  String toString() => 'WebClient {baseUrl:${dio.options.baseUrl}';

  void _throwIfNotSuccess(int? statusCode, {required String endpoint}) {
    if (statusCode == 403) {
      debugPrint("AccessDeniedException: $endpoint");
      throw AccessDeniedException(endpoint: endpoint);
    } else if (statusCode == 401) {
      debugPrint("UnauthorizedException: $endpoint");
      throw UnauthorizedException(endpoint: endpoint);
    } else if (statusCode == 404) {
      debugPrint("NotFoundException: $endpoint");
      throw NotFoundException(endpoint: endpoint);
    } else if (statusCode == 500) {
      debugPrint("ServerException: $endpoint");
      throw ServerException(endpoint: endpoint);
    }
  }
}
