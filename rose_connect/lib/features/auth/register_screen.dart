import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_router.dart';
import '../../core/services/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import 'auth_controller.dart';
import 'auth_service.dart';
import 'auth_widgets.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _identifier = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _accepted = false;
  bool _showConsentError = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _firstName.dispose();
    _identifier.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _showConsentError = !_accepted;
    });
    final valid = _formKey.currentState!.validate();
    if (!valid || !_accepted) return;
    setState(() => _loading = true);
    try {
      await ref.read(authControllerProvider.notifier).register(
            firstName: _firstName.text.trim(),
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
    final textTheme = Theme.of(context).textTheme;
    return AuthLayout(
      title: 'Créer un compte',
      subtitle: 'Un prénom ou un pseudonyme suffit. Aucune information '
          'médicale ne vous est demandée.',
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _firstName,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.givenName],
                  maxLength: 30,
                  decoration: const InputDecoration(
                    labelText: 'Prénom ou pseudonyme',
                    counterText: '',
                  ),
                  validator: (value) => (value ?? '').trim().length < 2
                      ? 'Saisissez au moins 2 caractères.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
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
                    helperText: 'Pour vous connecter. Il n’est jamais affiché.',
                    helperMaxLines: 2,
                  ),
                  validator: (value) => Identifier.normalize(value ?? '') == null
                      ? 'Saisissez un e-mail ou un numéro à 8 chiffres.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  controller: _password,
                  label: 'Mot de passe',
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => (value ?? '').length < 8
                      ? 'Au moins 8 caractères.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                PasswordField(
                  controller: _confirm,
                  label: 'Confirmer le mot de passe',
                  autofillHints: const [AutofillHints.newPassword],
                  validator: (value) => value != _password.text
                      ? 'Les mots de passe ne correspondent pas.'
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                _ConsentTile(
                  value: _accepted,
                  showError: _showConsentError,
                  onChanged: (value) => setState(() {
                    _accepted = value;
                    if (value) _showConsentError = false;
                  }),
                ),
                const SizedBox(height: AppSpacing.md),
                if (_error != null) FormErrorBox(_error!),
                SubmitButton(
                  label: 'Créer mon compte',
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text('Déjà un compte ?', style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.pushReplacement(AppRoutes.login),
                      child: const Text('Se connecter'),
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

class _ConsentTile extends StatelessWidget {
  const _ConsentTile({
    required this.value,
    required this.showError,
    required this.onChanged,
  });

  final bool value;
  final bool showError;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: value,
                  onChanged: (v) => onChanged(v ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'J’ai 18 ans ou plus et j’accepte les conditions générales '
                      'd’utilisation et la politique de confidentialité.',
                      style: textTheme.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 36),
          child: Wrap(
            spacing: 4,
            children: [
              TextButton(
                onPressed: () => context.push(AppRoutes.terms),
                child: const Text('Lire les CGU'),
              ),
              TextButton(
                onPressed: () => context.push(AppRoutes.privacy),
                child: const Text('Lire la politique'),
              ),
            ],
          ),
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              'Vous devez accepter les conditions pour créer un compte.',
              style: textTheme.bodySmall?.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }
}
