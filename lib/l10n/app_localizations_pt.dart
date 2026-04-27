// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Organiza Grana';

  @override
  String get helloWorld => 'Olá Mundo!';

  @override
  String get validationsEmailRequired => 'Informe seu e-mail';

  @override
  String get validationsEmailInvalid => 'Informe um e-mail valido';

  @override
  String get validationsPasswordRequired => 'Informe sua senha';
}
