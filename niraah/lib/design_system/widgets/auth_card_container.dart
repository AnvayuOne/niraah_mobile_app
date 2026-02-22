import 'package:flutter/material.dart';

class AuthCardContainer extends StatelessWidget {
  const AuthCardContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: child,
      ),
    );
  }
}
