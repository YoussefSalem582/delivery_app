import 'package:delivery_app/shared/widgets/navigation/shell_app_bar_logo.dart';
import 'package:flutter/material.dart';

/// Standard AppBar for main-shell tab screens (passenger and driver).
class ShellTabAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ShellTabAppBar({
    super.key,
    required this.title,
    this.actions = const [],
    this.backgroundColor,
    this.foregroundColor,
    this.titleStyle,
    this.surfaceTintColor,
  });

  final Widget title;
  final List<Widget> actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleStyle;
  final Color? surfaceTintColor;

  @override
  Size get preferredSize => const Size.fromHeight(ShellAppBarLogo.tabToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? scheme.surface,
      foregroundColor: foregroundColor,
      surfaceTintColor: surfaceTintColor,
      toolbarHeight: ShellAppBarLogo.tabToolbarHeight,
      leadingWidth: ShellAppBarLogo.leadingWidth,
      automaticallyImplyLeading: false,
      leading: const ShellAppBarLogo(),
      title: DefaultTextStyle(
        style: titleStyle ?? Theme.of(context).textTheme.titleLarge!,
        child: title,
      ),
      actions: actions,
    );
  }
}
