import 'package:flutter/material.dart';
import 'Responsive_Utils.dart';
import 'colors.dart';

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String label;
  final bool showBackIcon;

  const DefaultAppBar({
    super.key,
    required this.label,
    this.showBackIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    return Container(
      height: responsive.screenHeight < 700 ? 140 : 110,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            primaryColor,
            primaryColor,
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
      ),
      child: Padding(
        padding: responsive.getDefaultPadding().copyWith(
              top: responsive.screenHeight * 0.05,
              bottom: 10,
            ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (showBackIcon)
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: responsive.screenWidth * 0.08,
                  height: responsive.screenWidth * 0.08,
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: responsive.scaleFont(16),
                    color: Colors.white,
                  ),
                ),
              ),
            SizedBox(width: responsive.screenWidth * 0.04),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: responsive.getAppBarFontSize() * 1.2,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  letterSpacing: 0.7,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(120);
}
