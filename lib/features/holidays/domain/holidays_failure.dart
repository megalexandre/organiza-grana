enum HolidaysFailureType {
  unauthorized,
  network,
  server,
  invalidResponse,
}

class HolidaysFailure {
  const HolidaysFailure({
    required this.type,
    required this.message,
  });

  final HolidaysFailureType type;
  final String message;
}
