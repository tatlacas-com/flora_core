import 'package:equatable/equatable.dart';

enum NetworkExceptionType {
  accessDenied,
  unauthorized,
  notFound,
  noContent,
  serverError,
}

abstract class NetworkException extends Equatable implements Exception {
  final String? message;
  final String endpoint;
  final NetworkExceptionType exceptionType;

  const NetworkException({
    this.message,
    required this.endpoint,
    required this.exceptionType,
  });

  @override
  List<Object?> get props => [message, endpoint, exceptionType];
}

class AccessDeniedException extends NetworkException {
  const AccessDeniedException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.accessDenied);
}

class UnauthorizedException extends NetworkException {
  const UnauthorizedException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.unauthorized);
}

class NotFoundException extends NetworkException {
  const NotFoundException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.notFound);
}

class NoContentException extends NetworkException {
  const NoContentException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.noContent);
}

class ServerException extends NetworkException {
  const ServerException({required String endpoint, String? message})
      : super(
            endpoint: endpoint,
            message: message,
            exceptionType: NetworkExceptionType.serverError);
}
