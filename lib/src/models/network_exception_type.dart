enum NetworkExceptionType {
  other,
  unauthorized,
  accessDenied,
  notFound,
  expiredToken,
  server,
}

extension NetworkExceptionTypeExtension on NetworkExceptionType {
  NetworkExceptionType fromCode(int? code) {
    switch (code) {
      case -200:
        return NetworkExceptionType.expiredToken;
      case 401:
        return NetworkExceptionType.unauthorized;
      case 403:
        return NetworkExceptionType.accessDenied;
      case 404:
        return NetworkExceptionType.notFound;
      case 500:
        return NetworkExceptionType.server;
      default:
        return NetworkExceptionType.other;
    }
  }
}
