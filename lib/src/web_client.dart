import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;

import 'exceptions.dart';

abstract class WebClient extends Equatable {
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

  @override
  List<Object?> get props => [baseUrl, accessToken, params];

  @override
  String toString() => 'WebClient {baseUrl:$baseUrl}';

  Future<http.Response?> post(
    String endpoint,
    dynamic payload, {
    String? baseUrl,
    String? accessToken,
    bool jsonEncodedPayload = false,
  }) async {
    baseUrl ??= this.baseUrl;
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    accessToken = accessToken ?? this.accessToken;
    if (accessToken != null) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }
    final jsonPayload = jsonEncodedPayload ? payload : jsonEncode(payload);
    final uri = Uri.parse('$baseUrl$endpoint');
    debugPrint('HTTP POST: $uri');
    final response = await http
        .post(
          uri,
          body: jsonPayload,
          headers: headers,
        )
        .timeout(Duration(seconds: timeoutSeconds));
    debugPrint('HTTP POST RESPONSE: ${response.statusCode}');
    _throwIfNotSuccess(response.statusCode, endpoint: endpoint);
    return response;
  }

  Future<http.Response> postMultiPart(
    String endpoint,
    dynamic filePath, {
    String? baseUrl,
    String? accessToken,
    Map<String, String>? fields,
  }) async {
    baseUrl ??= this.baseUrl;
    var headers = <String, String>{};
    accessToken = accessToken ?? this.accessToken;
    if (accessToken != null) {
      headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }
    final uri = Uri.parse('$baseUrl$endpoint');
    var request = http.MultipartRequest("POST", uri);
    request.headers.addAll(headers);
    if (fields != null) {
      request.fields.addAll(fields);
    }
    await addFile(request, filePath);
    debugPrint('HTTP POST-MULTI_PART: $uri');
    final response = await request.send();
    debugPrint('HTTP POST-MULTI_PART RESPONSE: ${response.statusCode}');
    _throwIfNotSuccess(response.statusCode, endpoint: endpoint);
    return await http.Response.fromStream(response);
  }

  Future<void> addFile(http.MultipartRequest request, filePath) async {
     request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        await File(filePath).readAsBytes(),
      ),
    );
  }

  Future<http.StreamedResponse?> uploadFile({
    required String endpoint,
    required String filePath,
    required String fileName,
    String? baseUrl,
    String? accessToken,
  }) async {
    var file = File(filePath);
    final stream = http.ByteStream(file.openRead());
    var length = await file.length();
    baseUrl ??= this.baseUrl;

    var uri = Uri.parse('$baseUrl$endpoint');

    debugPrint('HTTP POST_FILE: $uri');
    var request = http.MultipartRequest("POST", uri);
    accessToken = accessToken ?? this.accessToken;
    if (accessToken != null) {
      request.headers[HttpHeaders.authorizationHeader] = "Bearer $accessToken";
    }
    var multipartFile =
        http.MultipartFile('file', stream, length, filename: fileName);
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    debugPrint('HTTP POST_FILE RESPONSE: ${response.statusCode}');
    _throwIfNotSuccess(response.statusCode, endpoint: endpoint);
    return response;
  }

  Future<http.Response?> get(
    dynamic endpoint, {
    String? baseUrl,
    String? accessToken,
  }) async {
    var headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    };
    accessToken = accessToken ?? this.accessToken;
    if (accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }
    Uri uri;
    if (endpoint is String) {
      uri = Uri.parse('${baseUrl ?? this.baseUrl}$endpoint');
    } else if (endpoint is Uri) {
      uri = endpoint;
    } else {
      debugPrint("Unsupported endpoint: $endpoint");
      throw ArgumentError('Unsupported endpoint');
    }
    debugPrint('HTTP GET: $uri');
    final response = await http
        .get(uri, headers: headers)
        .timeout(Duration(seconds: timeoutSeconds));
    debugPrint('HTTP GET RESPONSE: ${response.statusCode}');
    _throwIfNotSuccess(response.statusCode, endpoint: uri.toString());
    return response;
  }

  void _throwIfNotSuccess(int statusCode, {required String endpoint}) {
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
