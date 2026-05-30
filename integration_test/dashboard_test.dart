import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:integration_test/integration_test.dart';

import 'helpers/app_harness.dart';
import 'helpers/fixtures.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dashboard', () {
    Future<http.Client> buildClient({required void Function() onDashboardCall}) {
      return Future.value(MockClient((request) async {
        final key = '${request.method} ${request.url.path}';
        if (key == 'GET /api/dashboard/receivables_by_status') {
          onDashboardCall();
        }
        final table = <String, http.Response>{
          'GET /api/users/me': http.Response(
            encode(getMeBody),
            200,
            headers: {'content-type': 'application/json'},
          ),
          'GET /api/dashboard/receivables_by_status': http.Response(
            encode(dashboardReceivablesByStatusBody()),
            200,
            headers: {'content-type': 'application/json'},
          ),
          'GET /api/dashboard/summary': http.Response(
            encode(dashboardSummaryBody()),
            200,
            headers: {'content-type': 'application/json'},
          ),
          'GET /api/receivables': http.Response(
            encode(receivablesPageBody()),
            200,
            headers: {'content-type': 'application/json'},
          ),
        };
        return table[key] ?? http.Response('{"error":"not found"}', 404);
      }));
    }

    testWidgets('recarrega dados ao retornar de sub-rota', (tester) async {
      var dashboardCallCount = 0;
      final client = await buildClient(onDashboardCall: () => dashboardCallCount++);

      await pumpAuthenticated(tester, client, fakeJwt());

      expect(dashboardCallCount, 1);

      await tester.tap(find.text('Recebíveis'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Dashboard'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(dashboardCallCount, 2);
    });
  });
}
