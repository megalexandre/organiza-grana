import 'package:flutter_test/flutter_test.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input.dart';
import 'package:organizagrana/features/bordero/domain/bordero_input_item.dart';

void main() {
  final item = BorderoInputItem(
    amountCents: 100000,
    dueDate: DateTime(2026, 7, 24),
    awaitingDays: 2,
  );

  group('BorderoInputItem — regra de negócio: status draft', () {
    test('toJson() inclui status "draft"', () {
      expect(item.toJson()['status'], equals('draft'));
    });

    test('toJson() inclui os demais campos obrigatórios', () {
      final json = item.toJson();
      expect(json['amount_cents'], equals(100000));
      expect(json['due_date'], equals('2026-07-24'));
      expect(json['awaiting_days'], equals(2));
    });
  });

  group('BorderoInput.toSaveJson() — regra de negócio', () {
    test('itens novos (sem ID) são enviados em "receivables" com status "draft"', () {
      final input = BorderoInput(
        changeDate: DateTime(2026, 5, 24),
        monthlyRatePercent: 2.0,
        allItems: [item],
        newItems: [item],
      );

      final json = input.toSaveJson();

      expect(json.containsKey('receivables'), isTrue);
      expect(json['receivables'], hasLength(1));
      expect(json['receivables'][0]['status'], equals('draft'));
    });

    test('itens existentes (com ID) são enviados em "receivable_ids", não em "receivables"', () {
      final input = BorderoInput(
        changeDate: DateTime(2026, 5, 24),
        monthlyRatePercent: 2.0,
        allItems: [item],
        existingReceivableIds: ['rcv-abc'],
      );

      final json = input.toSaveJson();

      expect(json['receivable_ids'], equals(['rcv-abc']));
      expect(json.containsKey('receivables'), isFalse);
    });

    test('mistura: itens novos em "receivables" e existentes em "receivable_ids"', () {
      final input = BorderoInput(
        changeDate: DateTime(2026, 5, 24),
        monthlyRatePercent: 2.0,
        allItems: [item, item],
        newItems: [item],
        existingReceivableIds: ['rcv-existente'],
      );

      final json = input.toSaveJson();

      expect(json['receivable_ids'], equals(['rcv-existente']));
      expect(json['receivables'], hasLength(1));
      expect(json['receivables'][0]['status'], equals('draft'));
    });
  });

  group('BorderoInput.toCalculateJson()', () {
    test('envia todos os itens em "receivables"', () {
      final input = BorderoInput(
        changeDate: DateTime(2026, 5, 24),
        monthlyRatePercent: 2.0,
        allItems: [item, item],
        existingReceivableIds: ['rcv-1'],
      );

      final json = input.toCalculateJson();

      expect(json['receivables'], hasLength(2));
      expect(json['receivable_ids'], equals(['rcv-1']));
    });
  });
}
