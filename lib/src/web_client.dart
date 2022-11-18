import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint;

import 'exceptions.dart';

abstract class WebClient extends Equatable {
  final Dio dio;
  final String? accessToken;

  WebClient({
    required this.dio,
    this.accessToken,
  }) {
    dio.interceptors.add(QueuedInterceptorsWrapper(
      onError: onDioError,
      onRequest: onDioRequest,
      onResponse: onDioResponse,
    ));
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

  void onDioError(DioError error, ErrorInterceptorHandler handler) {
    _throwIfNotSuccess(error.response?.statusCode,
        endpoint: error.requestOptions.uri.toString());
    handler.next(error);
  }

  void onDioRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (!options.headers.containsKey('Authorization') &&
        accessToken?.isNotEmpty == true) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    handler.next(options);
  }

  void onDioResponse(
      Response<dynamic> response, ResponseInterceptorHandler handler) {
    _throwIfNotSuccess(response.statusCode,
        endpoint: response.requestOptions.uri.toString());
    handler.next(response);
  }
}
