// ignore_for_file: dangling_library_doc_comments, deprecated_member_use

/// Enhanced animation utilities and presets
/// 
/// Provides reusable animations and effects for better UI interactions.
/// 
/// Example:
/// ```dart
/// // Fade in animation
/// AnimatedFadeIn(
///   child: MyWidget(),
/// )
/// 
/// // Slide in from bottom
/// AnimatedSlideIn(
///   direction: SlideDirection.bottom,
///   child: MyWidget(),
/// )
/// 
/// // Scale animation on tap
/// AnimatedScaleTap(
///   onTap: () => doSomething(),
///   child: MyButton(),
/// )
/// ```
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Pre-configured animation presets
class AnimationPresets {
  /// Fade in animation
  static List<Effect> fadeIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return [
      FadeEffect(
        duration: duration,
        delay: delay,
        curve: Curves.easeInOut,
      ),
    ];
  }

  /// Slide in from direction
  static List<Effect> slideIn({
    SlideDirection direction = SlideDirection.bottom,
    Duration duration = const Duration(milliseconds: 400),
    Duration delay = Duration.zero,
  }) {
    Offset begin;
    switch (direction) {
      case SlideDirection.left:
        begin = const Offset(-1, 0);
        break;
      case SlideDirection.right:
        begin = const Offset(1, 0);
        break;
      case SlideDirection.top:
        begin = const Offset(0, -1);
        break;
      case SlideDirection.bottom:
        begin = const Offset(0, 1);
        break;
    }

    return [
      SlideEffect(
        begin: begin,
        end: Offset.zero,
        duration: duration,
        delay: delay,
        curve: Curves.easeOutCubic,
      ),
      FadeEffect(
        duration: duration,
        delay: delay,
      ),
    ];
  }

  /// Scale up animation
  static List<Effect> scaleIn({
    Duration duration = const Duration(milliseconds: 300),
    Duration delay = Duration.zero,
  }) {
    return [
      ScaleEffect(
        begin: const Offset(0.8, 0.8),
        end: const Offset(1, 1),
        duration: duration,
        delay: delay,
        curve: Curves.easeOutBack,
      ),
      FadeEffect(
        duration: duration,
        delay: delay,
      ),
    ];
  }

  /// Shimmer effect
  static List<Effect> shimmer({
    Duration duration = const Duration(milliseconds: 1500),
  }) {
    return [
      ShimmerEffect(
        duration: duration,
        color: Colors.white.withOpacity(0.5),
      ),
    ];
  }

  /// Bounce animation
  static List<Effect> bounce({
    Duration duration = const Duration(milliseconds: 600),
  }) {
    return [
      ScaleEffect(
        begin: const Offset(1, 1),
        end: const Offset(1.1, 1.1),
        duration: duration ~/ 2,
        curve: Curves.easeInOut,
      ),
      ScaleEffect(
        begin: const Offset(1.1, 1.1),
        end: const Offset(1, 1),
        duration: duration ~/ 2,
        delay: duration ~/ 2,
        curve: Curves.easeInOut,
      ),
    ];
  }

  /// Staggered list animation
  static List<Effect> staggeredList({
    int index = 0,
    Duration itemDuration = const Duration(milliseconds: 300),
    Duration staggerDelay = const Duration(milliseconds: 100),
  }) {
    final delay = staggerDelay * index;
    return [
      FadeEffect(
        duration: itemDuration,
        delay: delay,
      ),
      SlideEffect(
        begin: const Offset(0, 0.2),
        end: Offset.zero,
        duration: itemDuration,
        delay: delay,
        curve: Curves.easeOutCubic,
      ),
    ];
  }
}

/// Slide direction enum
enum SlideDirection { left, right, top, bottom }

/// Animated fade in widget
class AnimatedFadeIn extends StatelessWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const AnimatedFadeIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 300),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(effects: AnimationPresets.fadeIn(
      duration: duration,
      delay: delay,
    ));
  }
}

/// Animated slide in widget
class AnimatedSlideIn extends StatelessWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final Duration delay;

  const AnimatedSlideIn({
    super.key,
    required this.child,
    this.direction = SlideDirection.bottom,
    this.duration = const Duration(milliseconds: 400),
    this.delay = Duration.zero,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(effects: AnimationPresets.slideIn(
      direction: direction,
      duration: duration,
      delay: delay,
    ));
  }
}

/// Animated scale tap (press effect)
class AnimatedScaleTap extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;

  const AnimatedScaleTap({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
  });

  @override
  State<AnimatedScaleTap> createState() => _AnimatedScaleTapState();
}

class _AnimatedScaleTapState extends State<AnimatedScaleTap>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleFactor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

/// Animated list item with stagger effect
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;

  const AnimatedListItem({
    super.key,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return child.animate(effects: AnimationPresets.staggeredList(index: index));
  }
}

/// Pulsing animation widget
class PulsingWidget extends StatelessWidget {
  final Widget child;
  final Duration duration;

  const PulsingWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: duration ~/ 2,
        )
        .then()
        .scale(
          begin: const Offset(1.05, 1.05),
          end: const Offset(1, 1),
          duration: duration ~/ 2,
        );
  }
}
