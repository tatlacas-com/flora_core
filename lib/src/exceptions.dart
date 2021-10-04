class AccessDeniedException implements Exception {
  final String? message;
  final String endpoint;

  const AccessDeniedException({required this.endpoint,this.message});

  @override
  String toString() {
    return 'AccessDeniedException {endpoint:$endpoint, message:$message}';
  }
}

class UnauthorizedException implements Exception {
  final String endpoint;
  const UnauthorizedException({required this.endpoint});

  @override
  String toString() {
    return 'UnauthorizedException {endpoint:$endpoint}';
  }
}

class NotFoundException implements Exception {
  final String endpoint;
  const NotFoundException({required this.endpoint});

  @override
  String toString() {
    return 'NotFoundException {endpoint:$endpoint}';
  }
}

class NoContentException implements Exception {
  final String endpoint;
  const NoContentException({required this.endpoint});

  @override
  String toString() {
    return 'NoContentException {endpoint:$endpoint}';
  }
}

class ServerException implements Exception {
  final String endpoint;
  const ServerException({required this.endpoint});

  @override
  String toString() {
    return 'ServerException {endpoint:$endpoint}';
  }
}
