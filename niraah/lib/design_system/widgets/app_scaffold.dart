import 'package:flutter/material.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.body,
    super.key,
    this.title,
    this.showAppBar = true,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.backgroundColor,
  });

  final String? title;
  final Widget body;
  final bool showAppBar;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(title ?? ''),
              actions: actions,
              leading: leading,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
