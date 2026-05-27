import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth_choice/auth_choice_header.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth_choice/auth_choice_legal_note.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth_choice/auth_choice_options.dart';
import 'package:delivery_app/features/auth/presentation/widgets/onboarding/onboarding_background.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:flutter/material.dart';

@RoutePage()
class AuthChoicePage extends StatelessWidget {
  const AuthChoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const OnboardingBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: NoktaSpacing.lg,
                    vertical: NoktaSpacing.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - NoktaSpacing.md * 2,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          const AuthChoiceHeader(),
                          const Spacer(flex: 2),
                          AuthChoiceOptions(
                            onSignUp: () => context.router.push(
                              AuthCredentialShellRoute(
                                children: const [RegisterRoute()],
                              ),
                            ),
                            onSignIn: () => context.router.push(
                              const AuthCredentialShellRoute(),
                            ),
                          ),
                          const Spacer(),
                          const AuthChoiceLegalNote(),
                          const SizedBox(height: NoktaSpacing.md),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
