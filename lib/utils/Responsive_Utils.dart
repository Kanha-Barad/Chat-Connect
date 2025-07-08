import 'package:flutter/material.dart';

class ResponsiveUtils {
  final BuildContext context;
  final double screenWidth;
  final double screenHeight;
  final double textScaleFactor;

  ResponsiveUtils(this.context)
      : screenWidth = MediaQuery.of(context).size.width,
        screenHeight = MediaQuery.of(context).size.height,
        textScaleFactor = MediaQuery.of(context).textScaleFactor;

  // Base width (e.g., iPhone 11) for scaling
  static const double baseWidth = 375.0;

  double scaleFont(double baseSize) {
    return (baseSize * (screenWidth / baseWidth))
        .clamp(baseSize * 0.9, baseSize * 1.2) *
        textScaleFactor;
  }

  double getAppBarFontSize() => scaleFont(16);
  double getTitleFontSize() => scaleFont(14);
  double getBodyFontSize() => scaleFont(12);
  double getNormalRangeFontSize() => scaleFont(10);

  EdgeInsets getDefaultPadding() {
    return EdgeInsets.all(screenWidth > 600 ? 20 : 16);
  }
}
