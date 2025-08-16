import 'dart:ui';
import 'package:flutter/material.dart';

class UpdatableContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;

  const UpdatableContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  _UpdatableContainerState createState() => _UpdatableContainerState();
}

class _UpdatableContainerState extends State<UpdatableContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _glowAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
  }

  @override
  void didUpdateWidget(UpdatableContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate when properties change
    if (oldWidget.width != widget.width ||
        oldWidget.height != widget.height ||
        oldWidget.child != widget.child) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, animatedChild) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                // Enhanced outer glow with animation
                BoxShadow(
                  color:
                      (isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.blue.withOpacity(
                            0.2 * _glowAnimation.value,
                          )),
                  blurRadius: 25 * _glowAnimation.value,
                  spreadRadius: 3 * _glowAnimation.value,
                  offset: const Offset(0, 0),
                ),
                // Secondary glow (iPhone 16 style)
                BoxShadow(
                  color:
                      (isDark
                          ? Colors.cyan.withOpacity(0.08)
                          : Colors.purple.withOpacity(
                            0.15 * _glowAnimation.value,
                          )),
                  blurRadius: 35 * _glowAnimation.value,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
                // Main drop shadow
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 10),
                ),
                // Inner highlight (top-left)
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.1 : 0.2),
                  blurRadius: 12,
                  spreadRadius: -6,
                  offset: const Offset(-6, -6),
                ),
                // Inner shadow (bottom-right)
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.15)
                          : Colors.grey.withOpacity(0.08),
                  blurRadius: 10,
                  spreadRadius: -4,
                  offset: const Offset(4, 4),
                ),
                // Floating panel elevation
                BoxShadow(
                  color:
                      (isDark
                          ? Colors.white.withOpacity(0.03)
                          : Colors.black.withOpacity(0.04)),
                  blurRadius: 30,
                  spreadRadius: 6,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Multi-layer gradient overlay (iPhone 16 style)
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors:
                          isDark
                              ? [
                                Colors.white.withOpacity(0.15),
                                Colors.white.withOpacity(0.08),
                                Colors.white.withOpacity(0.05),
                                Colors.cyan.withOpacity(0.03),
                              ]
                              : [
                                Colors.white.withOpacity(0.4),
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                                Colors.blue.withOpacity(0.05),
                              ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    // Enhanced border with animation
                    border: Border.all(
                      color:
                          (isDark
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(
                                0.45 * _borderAnimation.value,
                              )),
                      width: 2.0 * _borderAnimation.value,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      // Inner subtle glow
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(isDark ? 0.06 : 0.12),
                          blurRadius: 15,
                          spreadRadius: -8,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.1),
                              end: Offset.zero,
                            ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
