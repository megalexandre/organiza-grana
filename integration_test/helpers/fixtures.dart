import 'dart:convert';

// Gera um JWT falso com exp no futuro — suficiente para AuthTokens.fromJwt.
String fakeJwt([String email = 'test@example.com']) {
  final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  final exp = now + 365 * 24 * 3600;
  final header = base64Url
      .encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'))
      .replaceAll('=', '');
  final payload = base64Url
      .encode(utf8.encode(
        '{"sub":"user-1","email":"$email","iat":$now,"exp":$exp}',
      ))
      .replaceAll('=', '');
  return '$header.$payload.fakesig';
}

Map<String, dynamic> loginSuccessBody([String email = 'test@example.com']) => {
      'access_token': fakeJwt(email),
      'refresh_token': 'fake-refresh-token',
    };

const Map<String, dynamic> getMeBody = {
  'id': 'user-1',
  'email': 'test@example.com',
  'roles': ['user'],
  'photo_url': null,
};

Map<String, dynamic> receivablesPageBody({int count = 1}) => {
      'receivables': List.generate(
        count,
        (i) => {
          'id': 'rcv-${i + 1}',
          'amount_cents': (i + 1) * 100000,
          'due_date': '2026-07-${(i + 1).toString().padLeft(2, '0')}',
          'awaiting_days': 30 + i,
          'status': 'awaiting',
        },
      ),
      'summary': {
        'count': count,
        'total_amount_cents': count * 100000,
      },
      'pagination': {
        'current_page': 1,
        'per_page': 20,
        'total_pages': 1,
        'total_count': count,
      },
    };

const Map<String, dynamic> receivableDetailBody = {
  'receivable': {
    'id': 'rcv-1',
    'amount_cents': 100000,
    'due_date': '2026-07-01',
    'awaiting_days': 30,
    'status': 'awaiting',
    'notes': null,
  },
};

const Map<String, dynamic> savedBorderoBody = {
  'id': 'bdro-saved-1',
  'change_date': '2026-08-01',
  'total_amount_cents': 300000,
  'total_proceeds_cents': 291500,
  'total_interest_amount_cents': 8500,
};

const Map<String, dynamic> borderoResultBody = {
  'items': [
    {
      'amount_cents': 100000,
      'deposit_date': '2026-06-01',
      'settlement_date': '2026-07-01',
      'total_days': 30,
      'interest_rate_percent': 2.5,
      'interest_amount_cents': 2500,
      'proceeds_cents': 97500,
    }
  ],
  'total_amount_cents': 100000,
  'total_proceeds_cents': 97500,
  'total_interest_amount_cents': 2500,
  'average_days': 30.0,
};

Map<String, dynamic> holidaysCalendarBody(int year, int month) => {
      'year': year,
      'month': month,
      'days': [
        {
          'date': '$year-${month.toString().padLeft(2, '0')}-01',
          'weekend': false,
          'holiday': true,
          'business_day': false,
          'holiday_name': 'Dia do Trabalho',
        },
      ],
    };

const Map<String, dynamic> holidayOverrideBody = {
  'id': 'ovr-1',
  'date': '2026-06-10',
  'holiday': true,
  'name': 'Feriado Teste',
};

String encode(Map<String, dynamic> body) => jsonEncode(body);
