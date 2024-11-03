import 'package:flutter/material.dart';

class ShakeTransition extends AnimatedWidget {
  final Widget child;

  const ShakeTransition({
    super.key,
    required Animation<Offset> animation,
    required this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<Offset>;
    return SlideTransition(
      position: animation,
      child: child,
    );
  }
}