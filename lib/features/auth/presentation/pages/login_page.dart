import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/core/utils/app_toast.dart';
import 'package:delivery_app/core/widgets/nokta_brand_icon.dart';
import 'package:delivery_app/core/widgets/nokta_primary_button.dart';
import 'package:delivery_app/core/widgets/nokta_text_field.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/presentation/forms/login_inputs.dart';
import 'package:delivery_app/injection_container.dart';
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
    setState(() {
      _email = EmailInput.dirty(_emailController.text);
    });
  }

  void _onPasswordChanged() {
    setState(() {
      _password = PasswordInput.dirty(_passwordController.text);
    });
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

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.router.replaceAll([const MainShellRoute()]);
          } else if (state is AuthError) {
            AppToast.error(context, state.message);
          }
        },
        builder: (context, state) {
          final loading = state is AuthLoading;
          return Scaffold(
            backgroundColor: scheme.surface,
            body: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _DotPatternPainter(
                        color: scheme.primary.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(NoktaSpacing.md),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Container(
                          padding: const EdgeInsets.all(NoktaSpacing.lg),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLowest,
                            borderRadius:
                                BorderRadius.circular(NoktaSpacing.radiusSheet),
                            border: Border.all(
                              color: scheme.outlineVariant.withValues(alpha: 0.3),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x0A000000),
                                blurRadius: 24,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Center(
                                child: Hero(
                                  tag: 'app_logo',
                                  child: NoktaBrandIcon(size: 64),
                                ),
                              ),
                              const SizedBox(height: NoktaSpacing.sm),
                              Text(
                                'app_name'.tr(),
                                style: textTheme.headlineMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: NoktaSpacing.lg),
                              Text(
                                'login_title'.tr(),
                                style: textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: NoktaSpacing.xs),
                              Text(
                                'login_subtitle'.tr(),
                                style: textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: NoktaSpacing.lg),
                              NoktaTextField(
                                controller: _emailController,
                                hintText: 'demo@delivery.app',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                errorText: _emailErrorText(),
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: NoktaSpacing.md),
                              NoktaTextField(
                                controller: _passwordController,
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: true,
                                errorText: _passwordErrorText(),
                                textInputAction: TextInputAction.done,
                              ),
                              const SizedBox(height: NoktaSpacing.sm),
                              Text(
                                'login_hint'.tr(),
                                style: textTheme.labelSmall?.copyWith(
                                  color: scheme.outline,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: NoktaSpacing.lg),
                              NoktaPrimaryButton(
                                label: 'login'.tr(),
                                loading: loading,
                                onPressed:
                                    _isValid && !loading ? () => _submit(context) : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DotPatternPainter extends CustomPainter {
  _DotPatternPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const spacing = 16.0;
    const radius = 1.0;

    for (var x = 0.0; x < size.width; x += spacing) {
      for (var y = 0.0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
