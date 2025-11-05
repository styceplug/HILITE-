import 'package:flutter/material.dart';
import 'package:get/get.dart';

/*class Dimensions {
  static double screenWidth = Get.context!.width;
  static double screenHeight = Get.context!.height;

  static void init(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }

  // general
  //h
  static double height5 = screenHeight / 186.4;
  static double height10 = screenHeight / 93.2;
  static double height12 = screenHeight / 77.667;
  static double height13 = screenHeight / 71.692;
  static double height15 = screenHeight / 62.13;
  static double height18 = screenHeight / 51.778;
  static double height20 = screenHeight / 46.6;
  static double height22 = screenHeight / 42.364;
  static double height24 = screenHeight / 38.833;
  static double height28 = screenHeight / 33.285;
  static double height30 = screenHeight / 31.067;
  static double height33 = screenHeight / 28.242;
  static double height38 = screenHeight / 24.526;
  static double height39 = screenHeight / 23.897;
  static double height40 = screenHeight / 23.3;
  static double height43 = screenHeight / 21.674;
  static double height50 = screenHeight / 18.64;
  static double height52 = screenHeight / 17.923;
  static double height54 = screenHeight / 17.259;
  static double height65 = screenHeight / 14.338;
  static double height67 = screenHeight / 13.91;
  static double height70 = screenHeight / 13.314;
  static double height76 = screenHeight / 12.263;
  static double height100 = screenHeight / 9.32;
  static double height134 = screenHeight / 6.955;
  static double height150 = screenHeight / 6.213;
  static double height152 = screenHeight / 6.132;
  static double height161 = screenHeight / 5.789;
  static double height171 = screenHeight / 5.45;
  static double height218 = screenHeight / 4.275;
  static double height240 = screenHeight / 3.833;
  static double height293 = screenHeight / 3.181;
  static double height295 = screenHeight / 3.159;
  static double height313 = screenHeight / 2.978;

  //w
  static double width5 = screenWidth / 86;
  static double width10 = screenWidth / 43.0;
  static double width13 = screenWidth / 33.077;
  static double width15 = screenWidth / 28.67;
  static double width18 = screenWidth / 23.889;
  static double width20 = screenWidth / 21.5;
  static double width22 = screenWidth / 19.545;
  static double width24 = screenWidth / 17.917;
  static double width25 = screenWidth / 17.2;
  static double width28 = screenWidth / 15.357;
  static double width29 = screenWidth / 14.828;
  static double width30 = screenWidth / 14.33;
  static double width33 = screenWidth / 13.03;
  static double width39 = screenWidth / 11.026;
  static double width40 = screenWidth / 10.75;
  static double width43 = screenWidth / 10;
  static double width45 = screenWidth / 9.556;
  static double width50 = screenWidth / 8.6;
  static double width52 = screenWidth / 8.27;
  static double width70 = screenWidth / 6.143;
  static double width85 = screenWidth / 5.059;
  static double width100 = screenWidth / 4.3;
  static double width113 = screenWidth / 3.805;
  static double width167 = screenWidth / 2.575;
  static double width188 = screenWidth / 2.287;
  static double width240 = screenWidth / 1.792;
  static double width270 = screenWidth / 1.593;
  static double width285 = screenWidth / 1.509;
  static double width355 = screenWidth / 1.211;
  static double width360 = screenWidth / 1.194;

  // radius
  static double radius5 = screenHeight / 186.4;
  static double radius10 = screenHeight / 93.2;
  static double radius15 = screenHeight / 62.13;
  static double radius20 = screenHeight / 46.6;
  static double radius30 = screenHeight / 31.067;
  static double radius45 = screenHeight / 20.711;

  // fonts
  static double font8 = screenHeight / 116.5;
  static double font10 = screenHeight / 93.2;
  static double font12 = screenHeight / 77.667;
  static double font13 = screenHeight / 71.692;
  static double font14 = screenHeight / 66.57;
  static double font15 = screenHeight / 62.133;
  static double font16 = screenHeight / 58.25;
  static double font17 = screenHeight / 54.824;
  static double font18 = screenHeight / 51.778;
  static double font20 = screenHeight / 46.6;
  static double font22 = screenHeight / 42.364;
  static double font23 = screenHeight / 40.52;
  static double font25 = screenHeight / 37.28;
  static double font26 = screenHeight / 35.85;
  static double font28 = screenHeight / 33.286;
  static double font30 = screenHeight / 31.067;

  // icons
  static double iconSize16 = screenHeight / 58.25;
  static double iconSize20 = screenHeight / 48.25;
  static double iconSize24 = screenHeight / 38.83;
  static double iconSize30 = screenHeight / 28.83;

  // custom
  //h
  static double splashLogoHeight = screenHeight / 2.505;

  static double dpHeight = screenHeight / 25.297;

  static double mainContainerHeight = screenHeight / 5.548;

  static double mainContainerHeight2 = screenHeight / 6;

  static double bottomNavIconHeight = screenHeight / 26.722;

  //w
  static double splashLogoWidth = screenWidth / 1.156;
  static double dpWidth = screenWidth / 11.671;
  static double bottomNavIconWidth = screenWidth / 11.944;
}*/

import 'package:flutter/material.dart';
import 'dart:math';

class Dimensions {
  static late double screenWidth;
  static late double screenHeight;
  static late double _scaleFactor;
  static late bool isSmallScreen;
  static late bool isMediumScreen;
  static late bool isLargeScreen;

  // Reference dimensions (design was made for these)
  static const double _referenceWidth = 430.0;  // Adjust to your design width
  static const double _referenceHeight = 932.0; // Adjust to your design height

  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    screenWidth = mediaQuery.size.width;
    screenHeight = mediaQuery.size.height;

    // Calculate scale factor with limits to prevent extreme scaling
    final widthScale = screenWidth / _referenceWidth;
    final heightScale = screenHeight / _referenceHeight;

    // Use the smaller scale factor and clamp it
    _scaleFactor = min(widthScale, heightScale).clamp(0.7, 1.3);

    // Screen size categories
    isSmallScreen = screenWidth < 360 || screenHeight < 640;
    isMediumScreen = screenWidth >= 360 && screenWidth < 600;
    isLargeScreen = screenWidth >= 600;
  }

  // Helper method to scale with minimum constraint
  static double _scale(double size, {double? min}) {
    final scaled = size * _scaleFactor;
    return min != null ? max(scaled, min) : scaled;
  }

  // Heights with minimum constraints
  static double get height5 => _scale(5, min: 4);
  static double get height10 => _scale(10, min: 8);
  static double get height12 => _scale(12, min: 10);
  static double get height13 => _scale(13, min: 11);
  static double get height15 => _scale(15, min: 12);
  static double get height18 => _scale(18, min: 15);
  static double get height20 => _scale(20, min: 16);
  static double get height22 => _scale(22, min: 18);
  static double get height24 => _scale(24, min: 20);
  static double get height28 => _scale(28, min: 24);
  static double get height30 => _scale(30, min: 25);
  static double get height33 => _scale(33, min: 28);
  static double get height38 => _scale(38, min: 32);
  static double get height39 => _scale(39, min: 33);
  static double get height40 => _scale(40, min: 34);
  static double get height43 => _scale(43, min: 36);
  static double get height50 => _scale(50, min: 42);
  static double get height52 => _scale(52, min: 44);
  static double get height54 => _scale(54, min: 46);
  static double get height65 => _scale(65, min: 55);
  static double get height67 => _scale(67, min: 57);
  static double get height70 => _scale(70, min: 60);
  static double get height76 => _scale(76, min: 65);
  static double get height100 => _scale(100, min: 85);
  static double get height134 => _scale(134, min: 110);
  static double get height150 => _scale(150, min: 120);
  static double get height152 => _scale(152, min: 122);
  static double get height161 => _scale(161, min: 130);
  static double get height171 => _scale(171, min: 140);
  static double get height218 => _scale(218, min: 180);
  static double get height240 => _scale(240, min: 200);
  static double get height293 => _scale(293, min: 240);
  static double get height295 => _scale(295, min: 245);
  static double get height313 => _scale(313, min: 260);

  // Widths with minimum constraints
  static double get width5 => _scale(5, min: 4);
  static double get width10 => _scale(10, min: 8);
  static double get width13 => _scale(13, min: 11);
  static double get width15 => _scale(15, min: 12);
  static double get width18 => _scale(18, min: 15);
  static double get width20 => _scale(20, min: 16);
  static double get width22 => _scale(22, min: 18);
  static double get width24 => _scale(24, min: 20);
  static double get width25 => _scale(25, min: 21);
  static double get width28 => _scale(28, min: 24);
  static double get width29 => _scale(29, min: 25);
  static double get width30 => _scale(30, min: 25);
  static double get width33 => _scale(33, min: 28);
  static double get width39 => _scale(39, min: 33);
  static double get width40 => _scale(40, min: 34);
  static double get width43 => _scale(43, min: 36);
  static double get width45 => _scale(45, min: 38);
  static double get width50 => _scale(50, min: 42);
  static double get width52 => _scale(52, min: 44);
  static double get width70 => _scale(70, min: 60);
  static double get width85 => _scale(85, min: 72);
  static double get width100 => _scale(100, min: 85);
  static double get width113 => _scale(113, min: 95);
  static double get width167 => _scale(167, min: 140);
  static double get width188 => _scale(188, min: 160);
  static double get width240 => _scale(240, min: 200);
  static double get width270 => _scale(270, min: 230);
  static double get width285 => _scale(285, min: 240);
  static double get width355 => _scale(355, min: 300);
  static double get width360 => _scale(360, min: 305);

  // Radius
  static double get radius5 => _scale(5, min: 4);
  static double get radius10 => _scale(10, min: 8);
  static double get radius15 => _scale(15, min: 12);
  static double get radius20 => _scale(20, min: 16);
  static double get radius30 => _scale(30, min: 24);
  static double get radius45 => _scale(45, min: 36);

  // Fonts - these especially need minimum sizes for readability
  static double get font8 => _scale(8, min: 8);
  static double get font10 => _scale(10, min: 10);
  static double get font12 => _scale(12, min: 11);
  static double get font13 => _scale(13, min: 12);
  static double get font14 => _scale(14, min: 13);
  static double get font15 => _scale(15, min: 14);
  static double get font16 => _scale(16, min: 15);
  static double get font17 => _scale(17, min: 16);
  static double get font18 => _scale(18, min: 17);
  static double get font20 => _scale(20, min: 18);
  static double get font22 => _scale(22, min: 20);
  static double get font23 => _scale(23, min: 21);
  static double get font25 => _scale(25, min: 22);
  static double get font26 => _scale(26, min: 23);
  static double get font28 => _scale(28, min: 24);
  static double get font30 => _scale(30, min: 26);

  // Icons - minimum 16px for touch targets
  static double get iconSize16 => _scale(16, min: 16);
  static double get iconSize20 => _scale(20, min: 18);
  static double get iconSize24 => _scale(24, min: 22);
  static double get iconSize30 => _scale(30, min: 26);

  // Custom dimensions
  static double get splashLogoHeight => _scale(372, min: 280);
  static double get dpHeight => _scale(36.8, min: 32);
  static double get mainContainerHeight => _scale(168, min: 140);
  static double get mainContainerHeight2 => _scale(155, min: 130);
  static double get bottomNavIconHeight => _scale(34.9, min: 30);

  static double get splashLogoWidth => _scale(372, min: 300);
  static double get dpWidth => _scale(36.8, min: 32);
  static double get bottomNavIconWidth => _scale(36, min: 32);

  // Responsive padding - adjusts based on screen size
  static double get screenPadding => isSmallScreen ? 12.0 : isMediumScreen ? 16.0 : 20.0;

  // Responsive spacing multipliers
  static double get spacingMultiplier => isSmallScreen ? 0.8 : 1.0;
}