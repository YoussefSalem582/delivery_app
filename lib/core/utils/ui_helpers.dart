import 'package:delivery_app/core/architecture/entities/trip_entity.dart';
import 'package:delivery_app/core/widgets/nokta_loading_ring.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

String tripStatusLabel(TripStatus status) {
  return 'status_${status.name}'.tr();
}

Color tripStatusColor(TripStatus status, BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return switch (status) {
    TripStatus.requested => scheme.outline,
    TripStatus.accepted => scheme.primary,
    TripStatus.driverArrived => scheme.tertiary,
    TripStatus.inProgress => scheme.secondary,
    TripStatus.completed => Colors.green,
    TripStatus.cancelled => scheme.error,
  };
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const NoktaLoadingRing(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(message!.tr()),
          ],
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              FilledButton(onPressed: onRetry, child: Text('retry'.tr())),
            ],
          ],
        ),
      ),
    );
  }
}

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text('offline_mode'.tr()),
      leading: const Icon(Icons.cloud_off),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      actions: const [SizedBox.shrink()],
    );
  }
}
