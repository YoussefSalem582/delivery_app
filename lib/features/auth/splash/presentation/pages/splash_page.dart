import 'dart:async';

import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/auth/splash/presentation/splash_config.dart';
import 'package:delivery_app/features/auth/splash/presentation/widgets/splash_background.dart';
import 'package:delivery_app/features/auth/splash/presentation/widgets/splash_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: SplashConfig.displayDuration,
    )..forward();

    context.read<AuthBloc>().add(const AuthCheckRequested());
    unawaited(_finishSplash());
  }

  Future<void> _finishSplash() async {
    final authBloc = context.read<AuthBloc>();
    final authFuture = authBloc.stream.firstWhere(
      (state) =>
          state is AuthAuthenticated ||
          state is AuthUnauthenticated ||
          state is AuthError,
    );

    final results = await Future.wait([
      Future<void>.delayed(SplashConfig.displayDuration),
      authFuture,
    ]);

    if (!mounted) return;

    final authState = results[1] as AuthState;
    if (authState is AuthAuthenticated) {
      context.goNamed(RouteNames.home);
    } else {
      context.replaceNamed(RouteNames.onboarding);
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const SplashBackground(),
          AnimatedBuilder(
            animation: _progressController,
            builder: (context, _) {
              return SplashContent(progress: _progressController.value);
            },
          ),
        ],
      ),
    );
  }
}
