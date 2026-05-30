import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_api_client.dart';
import 'package:organizagrana/features/recebiveis/data/receivables_service.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_draft.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_status.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_update.dart';
import 'package:organizagrana/features/recebiveis/domain/receivable_sort.dart';
import 'package:organizagrana/features/recebiveis/domain/receivables_page_result.dart';
import 'package:organizagrana/features/recebiveis/presentation/widgets/add_receivable_dialog.dart';

// Verifica, no widget REAL (add_receivable_dialog), que o padding inferior do
// formulário acompanha o viewInsets do teclado — em vez de testar uma cópia da
// lógica como o teste anterior fazia.

class _NoopReceivablesApiClient implements ReceivablesApiClient {
  @override
  Future<Receivable> create(ReceivableDraft draft) => throw UnimplementedError();
  @override
  Future<void> delete(String id) => throw UnimplementedError();
  @override
  Future<Receivable> getById(String id) => throw UnimplementedError();
  @override
  Future<ReceivablesPageResult> listPage({
    required int page,
    required int perPage,
    bool withDiscarded = false,
    ReceivableSortField sortBy = ReceivableSortField.dueDate,
    ReceivableSortDirection sortDirection = ReceivableSortDirection.desc,
    String? borderoId,
  }) =>
      throw UnimplementedError();
  @override
  Future<void> changeStatus(String id, ReceivableStatus status) => throw UnimplementedError();
  @override
  Future<void> update(String id, ReceivableUpdate update) => throw UnimplementedError();
  @override
  Future<void> updateDraft(String id, ReceivableDraft draft) => throw UnimplementedError();
}

Widget _host(ReceivablesService service) {
  return MaterialApp(
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          // GestureDetector (sem ink) evita carregar o shader InkSparkle, que
          // falha no ambiente de teste.
          child: GestureDetector(
            onTap: () => showAddReceivableSheet(context, service: service),
            child: const Text('abrir'),
          ),
        ),
      ),
    ),
  );
}

double _formBottomPadding(WidgetTester tester) {
  final padding = tester.widget<Padding>(
    find.ancestor(of: find.byType(Form), matching: find.byType(Padding)).first,
  );
  return padding.padding.resolve(TextDirection.ltr).bottom;
}

void main() {
  late ReceivablesService service;

  setUp(() {
    service = ReceivablesService(_NoopReceivablesApiClient());
  });

  // Superfície estreita (< 600) para abrir como bottom sheet.
  void useNarrowView(WidgetTester tester, {double keyboardHeight = 0}) {
    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.viewInsets = FakeViewPadding(bottom: keyboardHeight);
    addTearDown(tester.view.reset);
  }

  testWidgets('sem teclado, padding inferior é apenas a base (24)', (tester) async {
    useNarrowView(tester);

    await tester.pumpWidget(_host(service));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(_formBottomPadding(tester), 24.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('com teclado, padding inferior soma a altura do teclado', (tester) async {
    useNarrowView(tester, keyboardHeight: 300);

    await tester.pumpWidget(_host(service));
    await tester.tap(find.text('abrir'));
    await tester.pumpAndSettle();

    expect(_formBottomPadding(tester), 24.0 + 300.0);
    expect(tester.takeException(), isNull);
  });
}
