import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/shared/presentation/forms/login_inputs.dart';
import 'package:delivery_app/features/auth/shared/presentation/utils/auth_navigation.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/auth_form_scaffold.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/login_demo_chip.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/login_form_card.dart';
import 'package:delivery_app/features/auth/shared/presentation/widgets/auth/auth_credential_header.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    setState(() => _email = EmailInput.dirty(_emailController.text));
  }

  void _onPasswordChanged() {
    setState(() => _password = PasswordInput.dirty(_passwordController.text));
  }

  void _fillDemoCredentials() {
    _emailController.text = LoginDemoChip.demoEmail;
    _passwordController.text = LoginDemoChip.demoPassword;
    setState(() {
      _email = EmailInput.dirty(LoginDemoChip.demoEmail);
      _password = PasswordInput.dirty(LoginDemoChip.demoPassword);
    });
    _passwordFocusNode.requestFocus();
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
    context.pushNamed(RouteNames.register);
  }

  void _goToForgotPassword(BuildContext context) {
    dismissAuthKeyboard();
    context.pushNamed(RouteNames.forgotPassword);
  }

  void _goBack(BuildContext context) {
    dismissAuthKeyboard();
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = context.watch<AuthBloc>().state is AuthLoading;

    return AuthFormScaffold(
      background: AuthFormBackground.gradient,
      alignTop: true,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: scheme.onSurface,
          ),
          onPressed: () => _goBack(context),
        ),
      ),
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthCredentialHeader(
            titleKey: 'login_title',
            subtitleKey: 'login_subtitle',
          ),
          const SizedBox(height: AppSpacing.xl),
          LoginFormCard(
            emailController: _emailController,
            passwordController: _passwordController,
            emailFocusNode: _emailFocusNode,
            passwordFocusNode: _passwordFocusNode,
            emailErrorText: _emailErrorText(),
            passwordErrorText: _passwordErrorText(),
            loading: loading,
            onSubmit: loading ? null : () => _submit(context),
            onForgotPassword: () => _goToForgotPassword(context),
            onFillDemo: _fillDemoCredentials,
            onCreateAccount: () => _goToRegister(context),
          ),
        ],
      ),
    );
  }
}
