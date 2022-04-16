import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;
import 'package:tatlacas_flutter_core/src/copy_with.dart';

import 'exceptions.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

class WebClient extends Equatable {
  final String baseUrl;
  final String? accessToken;
  final int timeoutSeconds;
  final Map<String, dynamic> params;

  const WebClient({
    required this.baseUrl,
    this.accessToken,
    this.timeoutSeconds = 15,
    this.params = const {},
  });

  WebClient copyWith(
          {String? baseUrl,
          CopyWith<String?>? accessToken,
          int? timeoutSeconds}) =>
      WebClient(
        baseUrl: baseUrl ?? this.baseUrl,
        accessToken: accessToken != null ? accessToken.value : this.accessToken,
        timeoutSeconds: timeoutSeconds ?? this.timeoutSeconds,
      );

  @override
  List<Object?> get props => [baseUrl, accessToken, params];

  @override
  String toString() => 'WebClient {baseUrl:$baseUrl}';

  Future<http.Response?> post(
    String endpoint,
    dynamic payload, {
    String? baseUrl,
    bool jsonEncodedPayload = false,
  }) async {
    baseUrl ??= this.baseUrl;
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (accessToken != null) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }
    final jsonPayload = jsonEncodedPayload ? payload : jsonEncode(payload);
    final response = await http
        .post(
          Uri.parse('$baseUrl$endpoint'),
          body: jsonPayload,
          headers: headers,
        )
        .timeout(Duration(seconds: timeoutSeconds));
    _throwIfNotSuccess(response.statusCode, endpoint: endpoint);
    return response;
  }

  Future<http.StreamedResponse?> uploadFile({
    required String endpoint,
    required String filePath,
    required String fileName,
    String? baseUrl,
  }) async {
    var file = File(filePath);
    final stream = http.ByteStream(file.openRead());
    var length = await file.length();
    baseUrl ??= this.baseUrl;

    var uri = Uri.parse('$baseUrl$endpoint');

    var request = http.MultipartRequest("POST", uri);
    if (accessToken != null) {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }
    var multipartFile =
        http.MultipartFile('file', stream, length, filename: fileName);
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    _throwIfNotSuccess(response.statusCode, endpoint: endpoint);
    return response;
  }

  Future<http.Response?> get(
    dynamic endpoint, {
    String? baseUrl,
  }) async {
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    Uri uri;
    if (endpoint is String) {
      uri = Uri.parse('${baseUrl ?? this.baseUrl}$endpoint');
    } else if (endpoint is Uri) {
      uri = endpoint;
    } else {
      if (kDebugMode) print("Unsupported endpoint: $endpoint");
      throw ArgumentError('Unsupported endpoint');
    }
    final response = await http
        .get(uri, headers: headers)
        .timeout(Duration(seconds: timeoutSeconds));
    _throwIfNotSuccess(response.statusCode, endpoint: uri.toString());
    return response;
  }

  void _throwIfNotSuccess(int statusCode, {required String endpoint}) {
    if (statusCode == 403) {
      if (kDebugMode) print("AccessDeniedException: $endpoint");
      throw AccessDeniedException(endpoint: endpoint);
    } else if (statusCode == 401) {
      if (kDebugMode) print("UnauthorizedException: $endpoint");
      throw UnauthorizedException(endpoint: endpoint);
    } else if (statusCode == 404) {
      if (kDebugMode) print("NotFoundException: $endpoint");
      throw NotFoundException(endpoint: endpoint);
    } else if (statusCode == 500) {
      if (kDebugMode) print("ServerException: $endpoint");
      throw ServerException(endpoint: endpoint);
    }
  }
}
