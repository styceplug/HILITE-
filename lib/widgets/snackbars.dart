import 'package:get/get.dart';
import 'package:flutter/material.dart';




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