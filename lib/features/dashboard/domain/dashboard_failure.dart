enum DashboardFailureType {
  unauthorized,
  network,
  server,
  invalidResponse,
}

class DashboardFailure {
  const DashboardFailure({required this.type, required this.message});

  final DashboardFailureType type;
  final String message;
}
