import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthChoiceLegalNote extends StatelessWidget {
  const AuthChoiceLegalNote({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Text(
      'auth_choice_legal'.tr(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: scheme.outline,
            height: 1.35,
          ),
      textAlign: TextAlign.center,
    );
  }
}
