import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/Responsive_Utils.dart';
import '../utils/colors.dart';
import '../utils/defaultAppbar.dart';
import '../view model/auth_view_model.dart';
import 'bottom_nav_screen.dart';
import 'navigation/profile_screen.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveUtils(context);

    final locales = {
      "English": const Locale('en'),
      "हिन्दी": const Locale('hi'),
      "العربية": const Locale('ar'),
    };

    return Scaffold(
      appBar: DefaultAppBar(
        showBackIcon: true,
        label: 'change_language'.tr(),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: responsive.screenWidth * 0.04,
          vertical: responsive.screenHeight * 0.02,
        ),
        children: locales.entries.map((entry) {
          return ListTile(
              title: Text(
                entry.key,
                style: TextStyle(
                  fontSize: responsive.getTitleFontSize(),
                  color: textColor,
                ),
              ),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString(
                    'selectedLocale', entry.value.languageCode);
                await context.setLocale(entry.value);

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => BottomNavScreen(
                            currentUserId: Provider.of<AuthViewModel>(context,
                                    listen: false)
                                .user!
                                .uid,
                          )),
                );
              });
        }).toList(),
      ),
    );
  }
}
