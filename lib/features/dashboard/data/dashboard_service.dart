import 'package:organizagrana/features/dashboard/data/dashboard_api_client.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/dashboard/domain/receivable_status_count.dart';

class DashboardService {
  DashboardService(this._apiClient);

  final DashboardApiClient _apiClient;

  Future<List<ReceivableStatusCount>> fetchReceivablesByStatus() async {
    try {
      return await _apiClient.fetchReceivablesByStatus();
    } on DashboardApiClientException catch (e) {
      throw DashboardFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  String _messageFor(DashboardFailureType type) => switch (type) {
        DashboardFailureType.network => 'Falha de rede ao conectar no servidor.',
        DashboardFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        DashboardFailureType.server => 'Falha no servidor.',
        DashboardFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
