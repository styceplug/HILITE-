import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';

class AppLoadingOverlay extends StatefulWidget {
  const AppLoadingOverlay({super.key});

  @override
  State<AppLoadingOverlay> createState() => _AppLoadingOverlayState();
}

class _AppLoadingOverlayState extends State<AppLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.3),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
             Container(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height240),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius20),
                color: AppColors.black
              ),
              child: CircularProgressIndicator(
                strokeWidth: 4,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}