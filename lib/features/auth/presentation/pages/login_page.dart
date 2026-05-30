import 'package:flutter/material.dart';
import 'package:organizagrana/features/auth/presentation/widgets/login_brand_content.dart';
import 'package:organizagrana/features/auth/presentation/widgets/piggy_coin_animation.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
import 'package:organizagrana/shared/validators/app_validators.dart';

const double _kTabletBreakpoint = 600;
const double _kDesktopBreakpoint = 1024;
const String _kLoginDomain = '@mail.com';

/// Normaliza o identificador de login: se o usuário já informou o domínio
/// `@mail.com`, mantém como está; caso contrário, concatena. Strings vazias
/// permanecem vazias (para a validação de "campo obrigatório" funcionar).
String _normalizeLoginEmail(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return value;
  if (value.toLowerCase().endsWith(_kLoginDomain)) return value;
  return '$value$_kLoginDomain';
}

class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onLogin,
  });

  final Future<void> Function({
    required String email,
    required String password,
  }) onLogin;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (!(_formKey.currentState!.validate())) return;

    setState(() => _isSubmitting = true);

    try {
      await widget.onLogin(
        email: _normalizeLoginEmail(_emailController.text),
        password: _passwordController.text,
      );
    } catch (error) {
      if (!mounted) return;
      final message = error.toString().replaceFirst('Exception: ', '').trim();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(
          content: Text(
            message.isEmpty ? 'Falha no login. Verifique os dados.' : message,
          ),
        ));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = _LoginForm(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      passwordFocusNode: _passwordFocusNode,
      obscurePassword: _obscurePassword,
      onTogglePasswordVisibility: () =>
          setState(() => _obscurePassword = !_obscurePassword),
      onSubmit: _submitLogin,
      isSubmitting: _isSubmitting,
    );

    final width = MediaQuery.sizeOf(context).width;
    return Scaffold(
      body: width >= _kDesktopBreakpoint
          ? _DesktopLayout(form: form)
          : width >= _kTabletBreakpoint
              ? _TabletLayout(form: form)
              : _MobileLayout(form: form),
    );
  }
}

// ─── Desktop ──────────────────────────────────────────────────────────────────

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ColoredBox(
      color: colorScheme.surfaceContainerLow,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (_, bc) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: bc.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 48,
                  ),
                  child: Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(16),
                    shadowColor: colorScheme.shadow.withValues(alpha: 0.8),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 380,
                            child: ColoredBox(
                              color: colorScheme.primary,
                              child: LoginBrandContent(
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 420,
                            child: ColoredBox(
                              color: colorScheme.surface,
                              child: Padding(
                                padding: const EdgeInsets.all(48),
                                child: Center(child: form),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Tablet ───────────────────────────────────────────────────────────────────

class _TabletLayout extends StatelessWidget {
  const _TabletLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ColoredBox(
            color: colorScheme.primaryContainer,
            child: LoginBrandContent(
              color: colorScheme.onPrimaryContainer,
              compact: true,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (_, bc) => SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: bc.maxHeight - 64),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: form,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mobile ───────────────────────────────────────────────────────────────────

class _MobileLayout extends StatelessWidget {
  const _MobileLayout({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: LayoutBuilder(
        builder: (_, bc) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: bc.maxHeight - 80),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: [
                      PiggyCoinAnimation(color: colorScheme.primary, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Organiza Grana',
                        style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  form,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.passwordFocusNode,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final FocusNode passwordFocusNode;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final roundedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: theme.colorScheme.outlineVariant),
    );

    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          border: roundedBorder,
          enabledBorder: roundedBorder,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.error),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: theme.colorScheme.error, width: 1.5),
          ),
        ),
      ),
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Entrar',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use seu e-mail e senha para acessar sua conta.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(passwordFocusNode);
              },
              decoration: const InputDecoration(hintText: 'E-mail'),
              // Valida o e-mail já normalizado, para aceitar tanto "usuario"
              // quanto "usuario@mail.com" sem alterar o que aparece em tela.
              validator: (value) =>
                  AppValidators.email(_normalizeLoginEmail(value ?? ''), l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              focusNode: passwordFocusNode,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isSubmitting) onSubmit();
              },
              decoration: InputDecoration(
                hintText: 'Senha',
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) => AppValidators.password(value, l10n),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: isSubmitting ? null : onSubmit,
                child: isSubmitting
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
