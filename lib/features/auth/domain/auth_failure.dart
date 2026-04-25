enum AuthFailureType {
  invalidInput,
  invalidCredentials,
  network,
  server,
  invalidResponse,
  sessionExpired,
}

class AuthFailure {
  final AuthFailureType type;
  final String message;

  const AuthFailure({
    required this.type,
    required this.message,
  });
}
