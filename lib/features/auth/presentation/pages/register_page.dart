import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/app_toast.dart';
import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/presentation/forms/login_inputs.dart';
import 'package:delivery_app/features/auth/presentation/forms/register_inputs.dart';
import 'package:delivery_app/features/auth/presentation/utils/auth_navigation.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_scaffold.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/register_form_card.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';

@RoutePage()
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  NameInput _name = const NameInput.pure();
  EmailInput _email = const EmailInput.pure();
  PasswordInput _password = const PasswordInput.pure();
  ConfirmPasswordInput _confirmPassword = const ConfirmPasswordInput.pure();
  bool _acceptedTerms = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _emailController.addListener(_onEmailChanged);
    _passwordController.addListener(_onPasswordChanged);
    _confirmPasswordController.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _nameController
      ..removeListener(_onNameChanged)
      ..dispose();
    _emailController
      ..removeListener(_onEmailChanged)
      ..dispose();
    _passwordController
      ..removeListener(_onPasswordChanged)
      ..dispose();
    _confirmPasswordController
      ..removeListener(_onConfirmPasswordChanged)
      ..dispose();
    super.dispose();
  }

  void _onNameChanged() {
    setState(() => _name = NameInput.dirty(_nameController.text));
  }

  void _onEmailChanged() {
    setState(() => _email = EmailInput.dirty(_emailController.text));
  }

  void _onPasswordChanged() {
    setState(() {
      _password = PasswordInput.dirty(_passwordController.text);
      if (!_confirmPassword.isPure) {
        _confirmPassword = ConfirmPasswordInput.dirty(
          _confirmPasswordController.text,
          password: _passwordController.text,
        );
      }
    });
  }

  void _onConfirmPasswordChanged() {
    setState(
      () => _confirmPassword = ConfirmPasswordInput.dirty(
        _confirmPasswordController.text,
        password: _passwordController.text,
      ),
    );
  }

  bool get _isValid =>
      Formz.validate([_name, _email, _password, _confirmPassword]) &&
      _acceptedTerms;

  String? _nameErrorText() {
    if (!_name.isPure && _name.error != null) {
      return switch (_name.error!) {
        NameValidationError.empty => 'error_required'.tr(),
        NameValidationError.tooShort => 'error_name_short'.tr(),
      };
    }
    return null;
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

  String? _passwordErrorText() {
    if (!_password.isPure && _password.error != null) {
      return switch (_password.error!) {
        PasswordValidationError.empty => 'error_required'.tr(),
        PasswordValidationError.tooShort => 'error_password_short'.tr(),
      };
    }
    return null;
  }

  String? _confirmPasswordErrorText() {
    if (!_confirmPassword.isPure && _confirmPassword.error != null) {
      return switch (_confirmPassword.error!) {
        ConfirmPasswordValidationError.empty => 'error_required'.tr(),
        ConfirmPasswordValidationError.mismatch => 'error_password_mismatch'.tr(),
      };
    }
    return null;
  }

  void _submit(BuildContext context) {
    dismissAuthKeyboard();
    setState(() {
      _name = NameInput.dirty(_nameController.text);
      _email = EmailInput.dirty(_emailController.text);
      _password = PasswordInput.dirty(_passwordController.text);
      _confirmPassword = ConfirmPasswordInput.dirty(
        _confirmPasswordController.text,
        password: _passwordController.text,
      );
    });
    if (!_acceptedTerms) {
      AppToast.error(context, 'register_terms_required'.tr());
      return;
    }
    if (!_isValid) return;
    context.read<AuthBloc>().add(
          AuthRegisterRequested(
            name: _name.value.trim(),
            email: _email.value,
            password: _password.value,
          ),
        );
  }

  void _goToLogin(BuildContext context) {
    dismissAuthKeyboard();
    context.router.navigate(const LoginRoute());
  }

  void _goBack(BuildContext context) {
    dismissAuthKeyboard();
    context.router.maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final loading = context.watch<AuthBloc>().state is AuthLoading;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          AppToast.error(context, state.message);
        }
      },
      child: AuthFormScaffold(
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
              child: NoktaBrandIcon(size: 48, filled: false),
            ),
            const SizedBox(height: NoktaSpacing.md),
            RegisterFormCard(
              nameController: _nameController,
              emailController: _emailController,
              passwordController: _passwordController,
              confirmPasswordController: _confirmPasswordController,
              nameErrorText: _nameErrorText(),
              emailErrorText: _emailErrorText(),
              passwordErrorText: _passwordErrorText(),
              confirmPasswordErrorText: _confirmPasswordErrorText(),
              acceptedTerms: _acceptedTerms,
              onTermsChanged: (v) => setState(() => _acceptedTerms = v),
              loading: loading,
              onSubmit: loading ? null : () => _submit(context),
              onSignIn: () => _goToLogin(context),
            ),
          ],
        ),
      ),
    );
  }
}
