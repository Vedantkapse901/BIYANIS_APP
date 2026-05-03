import 'package:flutter/material.dart';

class CustomAnimations {
  // Smooth checkbox animation
  static Animation<double> getCheckboxAnimation(
    AnimationController controller, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOutBack),
    );
  }

  // Scale animation for card tap
  static Animation<double> getScaleAnimation(
    AnimationController controller, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Tween<double>(begin: 1, end: 0.95).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );
  }

  // Smooth fade animation
  static Animation<double> getFadeAnimation(
    AnimationController controller, {
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeIn),
    );
  }

  // Slide animation from bottom
  static Animation<Offset> getSlideAnimation(
    AnimationController controller, {
    Duration duration = const Duration(milliseconds: 400),
  }) {
    return Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeOut),
    );
  }
}

// Page Transition Animation
class SmoothPageTransition extends PageRoute {
  final WidgetBuilder builder;
  final String? title;

  SmoothPageTransition({
    required this.builder,
    this.title,
  });

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  bool get opaque => false;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    return builder(context);
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return SlideTransition(
      position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: child,
    );
  }
}
