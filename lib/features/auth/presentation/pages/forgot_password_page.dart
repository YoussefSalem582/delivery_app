import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/presentation/forms/login_inputs.dart';
import 'package:delivery_app/features/auth/presentation/utils/auth_navigation.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_scaffold.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/forgot_password_form_card.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  EmailInput _email = const EmailInput.pure();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  String? _emailErrorText() {
    if (!_email.isPure && _email.error != null) {
      return switch (_email.error!) {
        EmailValidationError.empty => 'error_required'.tr(),
        EmailValidationError.invalid => 'error_email_invalid'.tr(),
      };
    }
    return null;
  }

  void _submit() {
    dismissAuthKeyboard();
    setState(() => _email = EmailInput.dirty(_emailController.text));
    if (_email.isNotValid) return;

    context.read<AuthBloc>().add(
          AuthForgotPasswordRequested(email: _email.value),
        );
  }

  void _goToLogin() {
    dismissAuthKeyboard();
    context.router.navigate(const LoginRoute());
  }

  void _goBack() {
    dismissAuthKeyboard();
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loading = state is AuthForgotPasswordLoading;
        final emailSent = state is AuthForgotPasswordSent;

        return AuthFormScaffold(
          appBar: AppBar(
            backgroundColor: scheme.surface.withValues(alpha: 0.92),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: _goBack,
            ),
          ),
          form: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: NoktaBrandIcon(size: 48, filled: false),
              ),
              const SizedBox(height: NoktaSpacing.md),
              ForgotPasswordFormCard(
                emailController: _emailController,
                emailErrorText: _emailErrorText(),
                loading: loading,
                emailSent: emailSent,
                onSubmit: loading ? null : _submit,
                onBackToLogin: _goToLogin,
              ),
            ],
          ),
        );
      },
    );
  }
}
