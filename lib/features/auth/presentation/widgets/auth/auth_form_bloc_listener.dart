import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/core/utils/app_toast.dart';
import 'package:delivery_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthFormBlocListener extends StatelessWidget {
  const AuthFormBlocListener({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.router.replaceAll([const MainShellRoute()]);
        } else if (state is AuthError) {
          AppToast.error(context, state.message);
        }
      },
      child: child,
    );
  }
}
