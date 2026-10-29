import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_theme.dart';
import 'auth_controller.dart';
import 'auth_service.dart';
import 'auth_widgets.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).login(
            identifier: Identifier.normalize(_identifier.text)!,
            password: _password.text,
          );
      if (mounted) context.go(AppRoutes.home);
    } on AppException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthLayout(
      title: 'Se connecter',
      subtitle: 'Retrouvez votre espace ROSE Connect.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _identifier,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.telephoneNumber,
                  ],
                  decoration: const InputDecoration(
                    labelText: 'E-mail ou numéro de téléphone',
                  ),
                  validator: (value) => Identifier.normalize(value ?? '') == null
                      ? 'Saisissez un e-mail ou un numéro à 8 chiffres.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  controller: _password,
                  label: 'Mot de passe',
                  onSubmitted: (_) => _submit(),
                  validator: (value) => (value ?? '').isEmpty
                      ? 'Saisissez votre mot de passe.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_error != null) FormErrorBox(_error!),
                SubmitButton(
                  label: 'Se connecter',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Pas encore de compte ?',
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () =>
                          context.pushReplacement(AppRoutes.register),
                      child: const Text('Créer un compte'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
