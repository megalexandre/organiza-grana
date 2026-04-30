enum BorderoFailureType {
  invalidInput,
  unauthorized,
  network,
  server,
  invalidResponse,
}

class BorderoFailure {
  const BorderoFailure({
    required this.type,
    required this.message,
  });

  final BorderoFailureType type;
  final String message;
}
