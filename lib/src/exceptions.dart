import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';

enum NetworkExceptionType {
  accessDenied,
  unauthorized,
  expiredToken,
  notFound,
  noContent,
  serverError,
  unknown,
}

abstract class NetworkException extends DioError
    with EquatableMixin
    implements Exception {
  final String? log;
  final String endpoint;
  final NetworkExceptionType exceptionType;

  NetworkException(
      {this.log,
      required this.endpoint,
      required this.exceptionType,
      required super.requestOptions});

  @override
  List<Object?> get props => [message, endpoint, exceptionType];
}

class AccessDeniedException extends NetworkException {
  AccessDeniedException(
      {required String endpoint, required super.requestOptions, super.log})
      : super(
            endpoint: endpoint,
            exceptionType: NetworkExceptionType.accessDenied);
}

class UnauthorizedException extends NetworkException {
  UnauthorizedException(
      {required String endpoint, required super.requestOptions, super.log})
      : super(
            endpoint: endpoint,
            exceptionType: NetworkExceptionType.unauthorized);
}

class ExpiredTokenException extends NetworkException {
  const ExpiredTokenException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.expiredToken);
}

class NotFoundException extends NetworkException {
  NotFoundException(
      {required String endpoint, required super.requestOptions, super.log})
      : super(endpoint: endpoint, exceptionType: NetworkExceptionType.notFound);
}

class NoContentException extends NetworkException {
  NoContentException(
      {required String endpoint, required super.requestOptions, super.log})
      : super(
            endpoint: endpoint, exceptionType: NetworkExceptionType.noContent);
}

class ServerException extends NetworkException {
  ServerException(
      {required String endpoint, required super.requestOptions, super.log})
      : super(
            endpoint: endpoint,
            exceptionType: NetworkExceptionType.serverError);
}
