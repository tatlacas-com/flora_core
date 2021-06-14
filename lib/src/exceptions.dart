class AccessDeniedException implements Exception {
  final String? message;

  const AccessDeniedException({this.message});
}

class UnauthorizedException implements Exception {}

class NotFoundException implements Exception {}

class NoContentException implements Exception {}

class ServerException implements Exception {}
