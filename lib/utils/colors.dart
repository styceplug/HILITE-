import 'dart:ui';

import 'package:flutter/material.dart';

class AppColors {

  // ===== Primary Branding =====
  static const Color primary = Color(0xFF0B1F33);
  static const Color secondary = Color(0xFFFFFFFF); // White

  // ===== Accent & Background =====
  static const Color accent = Color(0xFFF2F4F7); // Light gray for contrast/background
  static const Color bgColor = Color(0xFFF9FBFD);

  // ===== Status Colors =====
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFC62828);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF0288D1);

  // ===== Neutrals =====
  static const Color black = Color(0xFF141414);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey1 = Color(0xFFF3F3F3);
  static const Color grey2 = Color(0xFFE5E5E5);
  static const Color grey3 = Color(0xFFB8B8B8);
  static const Color grey4 = Color(0xFFADADAD);
  static const Color grey5 = Color(0xFF5F5F5F);

  // ===== Transparent Shades =====
  static const Color blueLight = Color(0x330A74DA); // 20% opacity blue
  static const Color blueLighter = Color(0x1A0A74DA); // 10% opacity blue

  // ===== Gradient =====
  static const LinearGradient blueWhiteGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0A74DA),
      Color(0xFFFFFFFF),
    ],
    stops: [0.0, 1.0],
  );

}