import 'package:flutter/material.dart';

import '../utils/colors.dart';

class BouncingDotsIndicator extends StatefulWidget {
  final Color? color;
  final double dotSize;
  final double spacing;

  const BouncingDotsIndicator({
    super.key,
    this.color = AppColors.accent,
    this.dotSize = 10.0,
    this.spacing = 8.0,
  });

  @override
  _BouncingDotsIndicatorState createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<BouncingDotsIndicator>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();

    _controllers = List.generate(
      4,
          (index) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
      )..repeat(reverse: true, period: const Duration(milliseconds: 800)),
    );

    _animations = _controllers
        .map((controller) =>
        Tween<double>(begin: 0, end: 10.0).animate(controller))
        .toList();

    // 🔹 Delay each dot's animation for a wave effect
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        _controllers[i].forward();
      });
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color dotColor = widget.color ?? (isDark ? Colors.white70 : Colors.black87);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
            (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.translate(
                offset: Offset(0, -_animations[index].value),
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: dotColor.withOpacity(0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }}