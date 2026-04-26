enum ReceivableFailureType {
  invalidInput,
  unauthorized,
  network,
  server,
  invalidResponse,
}

class ReceivableFailure {
  const ReceivableFailure({
    required this.type,
    required this.message,
  });

  final ReceivableFailureType type;
  final String message;
}
