import 'package:delivery_app/shared/spacing/app_spacing.dart';
import 'package:flutter/material.dart';

/// Transparent overlay AppBar for fullscreen map trip screens.
class MapOverlayAppBar extends StatelessWidget implements PreferredSizeWidget {
  const MapOverlayAppBar({
    super.key,
    required this.title,
    this.onBack,
  });

  final String title;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: AppSpacing.sm),
        child: Material(
          color: scheme.surfaceContainerLowest,
          shape: const CircleBorder(),
          elevation: 2,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack ?? () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
      title: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLowest.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: scheme.primary,
              ),
        ),
      ),
      centerTitle: true,
    );
  }
}

/// Fullscreen map layout with overlay AppBar and optional footer below the map body.
class MapTripScaffold extends StatelessWidget {
  const MapTripScaffold({
    super.key,
    required this.title,
    required this.body,
    this.onBack,
    this.footer,
    this.useOverlayAppBar = true,
  });

  final String title;
  final Widget body;
  final VoidCallback? onBack;
  final Widget? footer;
  final bool useOverlayAppBar;

  @override
  Widget build(BuildContext context) {
    if (footer != null) {
      return Scaffold(
        extendBodyBehindAppBar: useOverlayAppBar,
        appBar: useOverlayAppBar
            ? MapOverlayAppBar(title: title, onBack: onBack)
            : AppBar(title: Text(title)),
        body: Column(
          children: [
            Expanded(child: body),
            ?footer,
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: useOverlayAppBar,
      appBar: useOverlayAppBar
          ? MapOverlayAppBar(title: title, onBack: onBack)
          : AppBar(title: Text(title)),
      body: body,
    );
  }
}
