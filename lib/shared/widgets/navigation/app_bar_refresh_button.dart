import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Refresh action used in shell tab AppBars (trips, driver offers, jobs).
class AppBarRefreshIconButton extends StatelessWidget {
  const AppBarRefreshIconButton({
    super.key,
    required this.isRefreshing,
    required this.onPressed,
    this.tooltipKey = 'retry',
  });

  final bool isRefreshing;
  final VoidCallback? onPressed;
  final String tooltipKey;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltipKey.tr(),
      onPressed: isRefreshing ? null : onPressed,
      icon: isRefreshing
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.refresh),
    );
  }
}
