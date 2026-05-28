import 'package:delivery_app/shared/widgets/navigation/shell_tab_app_bar.dart';
import 'package:flutter/material.dart';

/// Scaffold wrapper shared by passenger and driver shell tab pages.
class ShellTabScaffold extends StatelessWidget {
  const ShellTabScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          backgroundColor ?? Theme.of(context).colorScheme.surfaceContainer,
      appBar: appBar,
      body: body,
    );
  }
}

/// Convenience factory for the common logo + title tab AppBar.
ShellTabAppBar shellTabAppBar({
  required Widget title,
  List<Widget> actions = const [],
  Color? backgroundColor,
  Color? foregroundColor,
  TextStyle? titleStyle,
  Color? surfaceTintColor,
}) {
  return ShellTabAppBar(
    title: title,
    actions: actions,
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    titleStyle: titleStyle,
    surfaceTintColor: surfaceTintColor,
  );
}
