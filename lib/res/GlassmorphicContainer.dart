import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicContainer extends StatefulWidget {
  final Widget child;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassmorphicContainer({
    Key? key,
    required this.child,
    this.width,
    this.height,
    this.onTap,
  }) : super(key: key);

  @override
  _GlassmorphicContainerState createState() => _GlassmorphicContainerState();
}

class _GlassmorphicContainerState extends State<GlassmorphicContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _glowAnimation = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
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
          scale: _scaleAnimation.value,
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
                          ? Colors.white.withOpacity(0.15)
                          : Colors.blue.withOpacity(0.25)) *
                      _glowAnimation.value,
                  blurRadius: 25 * _glowAnimation.value,
                  spreadRadius: 3 * _glowAnimation.value,
                  offset: const Offset(0, 0),
                ),
                // Dynamic secondary glow
                BoxShadow(
                  color:
                      (isDark
                          ? Colors.cyan.withOpacity(0.1)
                          : Colors.purple.withOpacity(0.15)) *
                      _glowAnimation.value,
                  blurRadius: 35 * _glowAnimation.value,
                  spreadRadius: 1,
                  offset: const Offset(0, 0),
                ),
                // Main drop shadow
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.4)
                          : Colors.black.withOpacity(0.15),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 12),
                ),
                // Inner highlight (top-left)
                BoxShadow(
                  color: Colors.white.withOpacity(isDark ? 0.12 : 0.25),
                  blurRadius: 15,
                  spreadRadius: -8,
                  offset: const Offset(-8, -8),
                ),
                // Inner shadow (bottom-right)
                BoxShadow(
                  color:
                      isDark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.grey.withOpacity(0.1),
                  blurRadius: 12,
                  spreadRadius: -6,
                  offset: const Offset(6, 6),
                ),
                // Floating panel elevation
                BoxShadow(
                  color:
                      (isDark
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05)),
                  blurRadius: 40,
                  spreadRadius: 8,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    // Multi-layer gradient overlay
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
                                Colors.white.withOpacity(0.35),
                                Colors.white.withOpacity(0.25),
                                Colors.white.withOpacity(0.15),
                                Colors.blue.withOpacity(0.08),
                              ],
                      stops: const [0.0, 0.3, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    // Enhanced border with animation
                    border: Border.all(
                      color:
                          (isDark
                              ? Colors.white.withOpacity(0.25)
                              : Colors.white.withOpacity(0.4)) *
                          _borderAnimation.value,
                      width: 2.0 * _borderAnimation.value,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      // Inner glow effect
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withOpacity(isDark ? 0.08 : 0.15),
                          blurRadius: 20,
                          spreadRadius: -10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContainer() {
    if (widget.onTap != null) {
      return GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onTap!();
        },
        onTapCancel: () => _controller.reverse(),
        child: build(context),
      );
    }
    return build(context);
  }

  @override
  Widget build(BuildContext context) {
    return _buildContainer();
  }
}

// PRESET VARIATIONS WITH ALL FEATURES
class GlassmorphicVariations {
  // Dynamic Island Style - iPhone 16 Feature
  static Widget dynamicIsland({
    required Widget child,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return GlassmorphicContainer(
      width: width ?? 200,
      height: height ?? 40,
      onTap: onTap,
      child: child,
    );
  }

  // Control Center Glass - iOS 16+ Style
  static Widget controlCenter({
    required Widget child,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return GlassmorphicContainer(
      width: width,
      height: height ?? 80,
      onTap: onTap,
      child: child,
    );
  }

  // Interactive Glass Button
  static Widget button({
    required Widget child,
    double? width,
    double? height,
    required VoidCallback onTap,
  }) {
    return GlassmorphicContainer(
      width: width ?? 160,
      height: height ?? 50,
      onTap: onTap,
      child: Center(child: child),
    );
  }

  // Floating Panel - Elevated Design
  static Widget floatingPanel({
    required Widget child,
    double? width,
    double? height,
    VoidCallback? onTap,
  }) {
    return GlassmorphicContainer(
      width: width,
      height: height ?? 120,
      onTap: onTap,
      child: child,
    );
  }
}

// COMPREHENSIVE USAGE EXAMPLES
class GlassmorphicShowcase extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Enhanced background for better glass effect
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 2.0,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade500,
              Colors.pink.shade400,
              Colors.orange.shade300,
            ],
            stops: const [0.0, 0.4, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Dynamic Island Example
                Center(
                  child: GlassmorphicVariations.dynamicIsland(
                    width: 220,
                    height: 45,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Dynamic Island',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                        Icon(Icons.music_note, color: Colors.white, size: 18),
                      ],
                    ),
                    onTap: () => print('Dynamic Island tapped!'),
                  ),
                ),

                SizedBox(height: 30),

                // Control Center Style
                GlassmorphicVariations.controlCenter(
                  width: double.infinity,
                  height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlIcon(Icons.wifi, 'WiFi'),
                      _buildControlIcon(Icons.bluetooth, 'Bluetooth'),
                      _buildControlIcon(Icons.airplanemode_active, 'Airplane'),
                      _buildControlIcon(Icons.flashlight_on, 'Flashlight'),
                    ],
                  ),
                  onTap: () => print('Control Center tapped!'),
                ),

                SizedBox(height: 25),

                // Full Feature Container
                GlassmorphicContainer(
                  width: double.infinity,
                  height: 140,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: Colors.white.withOpacity(0.2),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Glass Container',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'All Premium Features Included',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, color: Colors.white),
                        ],
                      ),
                      SizedBox(height: 15),
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple, Colors.pink],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => print('Full feature container tapped!'),
                ),

                SizedBox(height: 25),

                // Interactive Buttons Row
                Row(
                  children: [
                    Expanded(
                      child: GlassmorphicVariations.button(
                        height: 55,
                        child: Text(
                          'Button 1',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => print('Button 1 tapped!'),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                      child: GlassmorphicVariations.button(
                        height: 55,
                        child: Text(
                          'Button 2',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => print('Button 2 tapped!'),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 25),

                // Floating Panel
                GlassmorphicVariations.floatingPanel(
                  width: double.infinity,
                  height: 160,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          size: 40,
                          color: Colors.yellow.shade300,
                        ),
                      ),
                      SizedBox(height: 15),
                      Text(
                        'Floating Panel',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Elevated glass design',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => print('Floating panel tapped!'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlIcon(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
