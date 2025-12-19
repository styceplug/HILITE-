import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:math';
import 'package:confetti/confetti.dart';





class CustomSnackBar {
  static OverlayEntry? _overlayEntry;
  static bool _isVisible = false;

  /// --- 🔹 Top Slide-in SnackBar
  static void _show({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    if (_isVisible) return;
    _isVisible = true;

    final overlay = Overlay.of(Get.overlayContext!);
    final animationController = AnimationController(
      vsync: overlay!,
      duration: const Duration(milliseconds: 300),
    );

    final animation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOutCubic),
    );

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 15,
        right: 15,
        child: SlideTransition(
          position: animation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.95),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
    animationController.forward();

    Future.delayed(const Duration(seconds: 2), () async {
      await animationController.reverse();
      _overlayEntry?.remove();
      _overlayEntry = null;
      _isVisible = false;
      animationController.dispose();
    });
  }

  // ✅ SUCCESS
  static void success({required String message}) {
    _show(
      message: message,
      color: Colors.green,
      icon: Icons.check_circle_rounded,
    );
  }

  // ❌ FAILURE
  static void failure({required String message}) {
    _show(
      message: message,
      color: Colors.redAccent,
      icon: Icons.error_outline,
    );
  }

  // ⏳ PROCESSING
  static void processing({required String message}) {
    _show(
      message: message,
      color: Colors.blueAccent,
      icon: Icons.hourglass_empty,
    );
  }

  /// --- 🔹 Bottom Toast (Fade In / Fade Out)
  static void showToast({
    required String message,
    Color backgroundColor = Colors.black12,
    Duration duration = const Duration(seconds: 2),
  }) {
    final overlay = Overlay.of(Get.overlayContext!);
    if (overlay == null) return;

    final opacityNotifier = ValueNotifier<double>(0.0);

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 60,
        left: 24,
        right: 24,
        child: SafeArea(
          child: ValueListenableBuilder<double>(
            valueListenable: opacityNotifier,
            builder: (context, opacity, _) {
              return AnimatedOpacity(
                opacity: opacity,
                duration: const Duration(milliseconds: 250),
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: backgroundColor.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style:  TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Fade in
    opacityNotifier.value = 1.0;

    // Wait for duration
    Future.delayed(duration, () {
      opacityNotifier.value = 0.0;
      Future.delayed(const Duration(milliseconds: 250), () {
        overlayEntry.remove();
      });
    });
  }
}


class GiftSuccessDialog extends StatefulWidget {
  final double amount;
  const GiftSuccessDialog({Key? key, required this.amount}) : super(key: key);

  @override
  State<GiftSuccessDialog> createState() => _GiftSuccessDialogState();
}

class _GiftSuccessDialogState extends State<GiftSuccessDialog> {
  late ConfettiController _controllerCenter;

  @override
  void initState() {
    super.initState();
    _controllerCenter = ConfettiController(duration: const Duration(seconds: 2));
    // Start the party immediately
    _controllerCenter.play();
  }

  @override
  void dispose() {
    _controllerCenter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 1. The Actual Dialog Content
        Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Animated Icon
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.elasticOut,
                  builder: (context, double value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.green, size: 50),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                const Text(
                  "Gift Sent!",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  "You successfully sent ${widget.amount.toInt()} tokens.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text("Awesome!", style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 2. The Confetti Overlay (Explosion from center)
        ConfettiWidget(
          confettiController: _controllerCenter,
          blastDirectionality: BlastDirectionality.explosive, // radiate from center
          shouldLoop: false,
          colors: const [
            Colors.green,
            Colors.blue,
            Colors.pink,
            Colors.orange,
            Colors.purple
          ],
          createParticlePath: drawStar, // Draw stars instead of squares
        ),
      ],
    );
  }

  // Helper to draw Star shape
  Path drawStar(Size size) {
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = 360 / numberOfPoints;
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degToRad(degreesPerStep)) {
      path.lineTo(halfWidth + externalRadius * cos(step), halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + degToRad(halfDegreesPerStep)), halfWidth + internalRadius * sin(step + degToRad(halfDegreesPerStep)));
    }
    path.close();
    return path;
  }
}