import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_api_client.dart';
import 'package:organizagrana/features/dashboard/data/dashboard_service.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_failure.dart';
import 'package:organizagrana/features/dashboard/domain/dashboard_summary.dart';
import 'package:organizagrana/features/dashboard/domain/receivable_status_count.dart';
import 'package:organizagrana/features/dashboard/presentation/widgets/dashboard_summary_cards.dart';

class _FakeApiClient implements DashboardApiClient {
  _FakeApiClient(this._onSummary);

  final Future<DashboardSummary> Function() _onSummary;

  @override
  Future<DashboardSummary> fetchSummary() => _onSummary();

  @override
  Future<List<ReceivableStatusCount>> fetchReceivablesByStatus() async => const [];
}

// O widget usa GoRouter.of(context); montamos um router mínimo só com o widget.
Widget _host(DashboardService service) {
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(
          body: SingleChildScrollView(child: DashboardSummaryCards(service: service)),
        ),
      ),
    ],
  );
  return MaterialApp.router(routerConfig: router);
}

void main() {
  testWidgets('exibe os KPIs com valores formatados após carregar', (tester) async {
    final service = DashboardService(_FakeApiClient(() async => const DashboardSummary(
          totalAmountCents: 1879998,
          totalProceedsCents: 1722079,
          receivablesCount: 6,
          averageAwaitingDays: 63.0,
        )));

    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();

    expect(find.text('A receber'), findsOneWidget);
    expect(find.textContaining('17.220,79'), findsOneWidget); // total_proceeds
    expect(find.text('Recebíveis'), findsOneWidget);
    expect(find.text('6'), findsOneWidget);
  });

  testWidgets('mostra erro com ação de tentar novamente', (tester) async {
    var calls = 0;
    final service = DashboardService(_FakeApiClient(() async {
      calls++;
      throw const DashboardFailure(
        type: DashboardFailureType.network,
        message: 'Falha de rede',
      );
    }));

    await tester.pumpWidget(_host(service));
    await tester.pumpAndSettle();

    expect(find.text('Falha de rede'), findsOneWidget);
    expect(calls, 1);

    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(calls, 2);
  });
}
