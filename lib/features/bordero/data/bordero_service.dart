import 'package:organizagrana/features/bordero/data/bordero_api_client.dart';
import 'package:organizagrana/features/bordero/domain/bordero_failure.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_result.dart';
import 'package:organizagrana/features/bordero/domain/bordero_sort.dart';
import 'package:organizagrana/features/bordero/domain/borderos_page_result.dart';
import 'package:organizagrana/features/bordero/domain/saved_bordero.dart';

class BorderoService {
  BorderoService(this._apiClient);

  final BorderoApiClient _apiClient;

  Future<BorderosPageResult> listPage({
    required int page,
    required int perPage,
    BorderoSortField sortBy = BorderoSortField.changeDate,
    BorderoSortDirection sortDirection = BorderoSortDirection.desc,
  }) async {
    try {
      return await _apiClient.listPage(
        page: page,
        perPage: perPage,
        sortBy: sortBy,
        sortDirection: sortDirection,
      );
    } on BorderoApiClientException catch (e) {
      throw BorderoFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<BorderoResult> calculate(BorderoInput input) async {
    try {
      return await _apiClient.calculate(input);
    } on BorderoApiClientException catch (e) {
      throw BorderoFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  Future<SavedBordero> save(BorderoInput input) async {
    try {
      return await _apiClient.save(input);
    } on BorderoApiClientException catch (e) {
      throw BorderoFailure(type: e.type, message: _messageFor(e.type));
    }
  }

  String _messageFor(BorderoFailureType type) => switch (type) {
        BorderoFailureType.invalidInput => 'Dados inválidos para o borderô.',
        BorderoFailureType.network => 'Falha de rede ao conectar no servidor.',
        BorderoFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        BorderoFailureType.server => 'Falha no servidor.',
        BorderoFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
