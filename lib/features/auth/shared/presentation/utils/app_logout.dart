import 'package:delivery_app/config/routes/route_names.dart';
import 'package:delivery_app/features/auth/shared/presentation/bloc/auth_bloc.dart';
import 'package:delivery_app/features/driver/shared/presentation/cubit/app_mode_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Resets app mode and signs out — shared by passenger and driver profile tabs.
Future<void> performAppLogout(BuildContext context) async {
  await context.read<AppModeCubit>().resetToPassenger();
  if (!context.mounted) return;
  context.read<AuthBloc>().add(const AuthLogoutRequested());
  context.goNamed(RouteNames.splash);
}
