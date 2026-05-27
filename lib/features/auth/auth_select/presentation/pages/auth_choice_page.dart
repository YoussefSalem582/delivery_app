import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:delivery_app/features/auth/auth_select/presentation/widgets/auth_choice_header.dart';
import 'package:delivery_app/features/auth/auth_select/presentation/widgets/auth_choice_legal_note.dart';
import 'package:delivery_app/features/auth/auth_select/presentation/widgets/auth_choice_options.dart';
import 'package:delivery_app/features/auth/onboarding/presentation/widgets/onboarding_background.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - AppSpacing.md * 2,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const Spacer(flex: 2),
                          const AuthChoiceHeader(),
                          const Spacer(flex: 2),
                          AuthChoiceOptions(
                            onSignUp: () =>
                                context.pushNamed(RouteNames.register),
                            onSignIn: () => context.pushNamed(RouteNames.login),
                          ),
                          const Spacer(),
                          const AuthChoiceLegalNote(),
                          const SizedBox(height: AppSpacing.md),
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
