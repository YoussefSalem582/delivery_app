import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/presentation/forms/login_inputs.dart';
import 'package:delivery_app/features/auth/presentation/utils/auth_navigation.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_scaffold.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/login_form_card.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'demo@delivery.app');
  final _passwordController = TextEditingController(text: 'password');

  EmailInput _email = const EmailInput.pure();
  PasswordInput _password = const PasswordInput.pure();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
  }

  @override
  void dispose() {
    _emailController
      ..removeListener(_onEmailChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onPasswordChanged)
      ..dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() => _email = EmailInput.dirty(_emailController.text));
  }

  void _onPasswordChanged() {
    setState(() => _password = PasswordInput.dirty(_passwordController.text));
  }

  bool get _isValid => Formz.validate([_email, _password]);

  String? _emailErrorText() {
    if (!_email.isPure && _email.error != null) {
      return switch (_email.error!) {
        EmailValidationError.empty => 'error_required'.tr(),
        EmailValidationError.invalid => 'error_email_invalid'.tr(),
      };
    }
    return null;
  }

  String? _passwordErrorText() {
    if (!_password.isPure && _password.error != null) {
      return switch (_password.error!) {
        PasswordValidationError.empty => 'error_required'.tr(),
        PasswordValidationError.tooShort => 'error_password_short'.tr(),
      };
    }
    return null;
  }

  void _submit(BuildContext context) {
    dismissAuthKeyboard();
    setState(() {
      _email = EmailInput.dirty(_emailController.text);
      _password = PasswordInput.dirty(_passwordController.text);
    });
    if (!_isValid) return;
    context.read<AuthBloc>().add(
          AuthLoginRequested(
            email: _email.value,
            password: _password.value,
          ),
        );
  }

  void _goToRegister(BuildContext context) {
    dismissAuthKeyboard();
    context.router.navigate(const RegisterRoute());
  }

  void _goToForgotPassword(BuildContext context) {
    dismissAuthKeyboard();
    context.router.push(const ForgotPasswordRoute());
  }

  void _goBack(BuildContext context) {
    dismissAuthKeyboard();
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loading = context.watch<AuthBloc>().state is AuthLoading;

    return AuthFormScaffold(
      appBar: AppBar(
        backgroundColor: scheme.surface.withValues(alpha: 0.92),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => _goBack(context),
        ),
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Hero(
              tag: 'app_logo',
              child: NoktaBrandIcon(size: 56),
            ),
          ),
          const SizedBox(height: NoktaSpacing.sm),
          Text(
            'app_name'.tr(),
            style: textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: NoktaSpacing.md),
          LoginFormCard(
            emailController: _emailController,
            passwordController: _passwordController,
            emailErrorText: _emailErrorText(),
            passwordErrorText: _passwordErrorText(),
            loading: loading,
            onSubmit: loading ? null : () => _submit(context),
            onForgotPassword: () => _goToForgotPassword(context),
            onCreateAccount: () => _goToRegister(context),
          ),
        ],
      ),
    );
  }
}
