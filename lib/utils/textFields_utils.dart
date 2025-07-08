import 'package:flutter/material.dart';

import 'Responsive_Utils.dart';
import 'colors.dart';

Widget buildCustomLabel(String text, ResponsiveUtils responsive) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: responsive.getTitleFontSize(),
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}

Widget buildCustomTextField({
  required TextEditingController controller,
  required String hintText,
  required TextInputType keyboardType,
  required ResponsiveUtils responsive,
  bool obscureText = false,
  Widget? suffixIcon,
  void Function(String)? onChanged,
  FocusNode? focusNode,
  void Function(String)? onSubmit,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      onSubmitted: onSubmit,
      onChanged: onChanged,
      style: TextStyle(
        color: textColor,
        fontSize: responsive.getBodyFontSize(),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5), // faded charcoal grey
          fontSize: responsive.getBodyFontSize(),
          fontWeight: FontWeight.w400,
        ),
        suffixIcon: suffixIcon,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: backgroundPageColor, // subtle background
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentColor, width: 1),
        ),
      ),
    ),
  );
}

Widget buildCustomDropdownField<T>({
  required T? value,
  required String hintText,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
  required ResponsiveUtils responsive,
  bool isLoading = false,
}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: DropdownButtonFormField<T>(
      value: value,
      isExpanded: true,
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: textColor),
      style: TextStyle(
        color: textColor,
        fontSize: responsive.getBodyFontSize(),
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: backgroundPageColor,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        hintText: isLoading ? "Loading..." : hintText,
        hintStyle: TextStyle(
          color: textColor.withOpacity(0.5),
          fontSize: responsive.getBodyFontSize(),
          fontWeight: FontWeight.w400,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: accentColor),
        ),
      ),
      dropdownColor: Colors.white,
      items: isLoading ? [] : items,
      onChanged: isLoading ? null : onChanged,
    ),
  );
}

Widget buildButton({
  required String text,
  required VoidCallback onPressed,
  required bool isPrimary,
  required ResponsiveUtils responsive,
  double? width,
}) {
  final button = isPrimary
      ? ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor, // Soft Blue
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.09,
              fontSize: responsive.getTitleFontSize(),
            ),
          ),
        )
      : OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundPageColor,
            side: const BorderSide(color: accentColor, width: 1.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20),
          ),
          child: Text(
            text,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w500,
              fontSize: responsive.getTitleFontSize(),
            ),
          ),
        );

  return Padding(
    padding: const EdgeInsets.all(1.6),
    child: SizedBox(
      width: width ??
          (isPrimary
              ? responsive.screenWidth * 0.48
              : responsive.screenWidth * 0.3),
      height: 42,
      child: button,
    ),
  );
}
