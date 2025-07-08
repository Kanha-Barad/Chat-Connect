import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/Responsive_Utils.dart';
import '../utils/colors.dart'; // Adjust path if needed

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    return Scaffold(
      backgroundColor: backgroundPageColor,
      body: Center(
        child: Padding(
          padding: responsive.getDefaultPadding(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(responsive.screenWidth > 600 ? 32 : 24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.chat_bubble_rounded,
                  size: responsive.screenWidth > 600 ? 100 : 80,
                  color: primaryColor,
                ),
              ),
              SizedBox(height: responsive.screenWidth > 600 ? 32 : 24),
              Text(
                'app_name'.tr(),
                style: TextStyle(
                  fontSize: responsive.scaleFont(28),
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'splash_tagline'.tr(),
                style: TextStyle(
                  fontSize: responsive.scaleFont(16),
                  color: textColor.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
