import 'package:go_router/go_router.dart';
import 'package:delivery_app/shared/widgets/banners/app_toast.dart';
import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
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
          context.goNamed(RouteNames.home);
        } else if (state is AuthError) {
          AppToast.error(context, state.message);
        }
      },
      child: child,
    );
  }
}
