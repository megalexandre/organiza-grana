import 'package:organizagrana/app/app_theme.dart';
import 'package:organizagrana/l10n/app_localizations.dart';
import 'package:organizagrana/shared/validators/app_validators.dart';
import 'package:flutter/material.dart';


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
  final _emailContoller = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailContoller.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    final isValid = _formKey.currentState!.validate();
    final messenger = ScaffoldMessenger.of(context);

    if (!isValid) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Preencha os campos para continuar.'),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await widget.onLogin(
        email: _emailContoller.text.trim(),
        password: _passwordController.text,
      );

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        const SnackBar(content: Text('Login realizado com sucesso.')),
      );
    } catch (error) {
      final message = error
          .toString()
          .replaceFirst('Exception: ', '')
          .trim();
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            message.isEmpty
                ? 'Falha no login. Verifique os dados.'
                : message,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppPalette.info300, AppPalette.info500],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_person_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Acal Panel',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Seja bem Vindo',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 40),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? theme.colorScheme.surface : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.30),
                            blurRadius: 48,
                            offset: const Offset(0, 24),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(40),
                      child: _LoginForm(
                        formKey: _formKey,
                        emailController: _emailContoller,
                        passwordController: _passwordController,
                        obscurePassword: _obscurePassword,
                        onTogglePasswordVisibility: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        onSubmit: _submitLogin,
                        isSubmitting: _isSubmitting,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoginForm extends StatelessWidget {
  const _LoginForm({
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onTogglePasswordVisibility,
    required this.onSubmit,
    required this.isSubmitting,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final VoidCallback onTogglePasswordVisibility;
  final Future<void> Function() onSubmit;
  final bool isSubmitting;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!
;
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
            Text(
              'Entrar',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Use seu e-mail e senha para acessar sua conta.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isSubmitting) {
                  onSubmit();
                }
              },
              decoration: const InputDecoration(labelText: 'E-mail'),
              validator: (value) => AppValidators.email(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isSubmitting) {
                  onSubmit();
                }
              },
              decoration: InputDecoration(
                labelText: 'Senha',
                suffixIcon: IconButton(
                  onPressed: onTogglePasswordVisibility,
                  icon: Icon(
                    obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Informe sua senha';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : onSubmit,
                child: isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Login'),
              ),
            ),
          ],
        ),
      );
  }
}
