import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_failure.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_result.dart';

class ReceivablesService {
  ReceivablesService(this._apiClient);

  final ReceivablesApiClient _apiClient;

  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
  }) async {
    try {
      return await _apiClient.listPage(
        page: page,
        perPage: perPage,
        withDiscarded: withDiscarded,
      );
    } on ReceivablesApiClientException catch (e) {
      throw ReceivableFailure(
        type: e.type,
        message: _messageFor(e.type),
      );
    }
  }

  Future<ReceivableResult> create(ReceivableDraft draft) async {
    try {
      
      await _apiClient.create(draft);
      return const ReceivableResult.success();

    } on ReceivablesApiClientException catch (e) {
      return ReceivableResult.failure(ReceivableFailure(
        type: e.type,
        message: _messageFor(e.type),
      ));
    }
  }

  String _messageFor(ReceivableFailureType type) => switch (type) {
        ReceivableFailureType.invalidInput => 'Dados inválidos para o recebível.',
        ReceivableFailureType.network => 'Falha de rede ao conectar no servidor.',
        ReceivableFailureType.unauthorized => 'Sessão expirada. Faça login novamente.',
        ReceivableFailureType.server => 'Falha no servidor.',
        ReceivableFailureType.invalidResponse => 'Resposta inválida da API.',
      };
}
