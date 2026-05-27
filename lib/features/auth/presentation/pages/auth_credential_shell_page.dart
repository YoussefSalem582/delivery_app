import 'package:auto_route/auto_route.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth/auth_form_bloc_listener.dart';
import 'package:flutter/material.dart';

/// Hosts login/register with one [AuthBloc] for the whole sign-in flow.
@RoutePage()
class AuthCredentialShellPage extends StatelessWidget {
  const AuthCredentialShellPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthFormBlocListener(
      child: AutoRouter(),
    );
  }
}
