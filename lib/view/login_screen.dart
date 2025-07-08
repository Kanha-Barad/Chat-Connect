import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/Responsive_Utils.dart';
import '../utils/colors.dart';
import '../utils/textFields_utils.dart';
import '../view model/auth_view_model.dart';
import 'bottom_nav_screen.dart';
import 'navigation/home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? goToRegister;
  const LoginScreen({super.key, required this.goToRegister});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible = false;

  void _login() async {
    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    await authProvider.login(
        emailController.text.trim(), passwordController.text.trim(), context);

    if (authProvider.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              BottomNavScreen(currentUserId: authProvider.user!.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthViewModel>(context);
    final responsive = ResponsiveUtils(context);

    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Center(
            child: SingleChildScrollView(
              child: _buildLoginBox(authProvider, responsive),
            ),
          ),
          if (authProvider.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: const Center(
              child: Text(
                "Welcome to ChatConnect",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }

  Widget _buildLoginBox(
      AuthViewModel authProvider, ResponsiveUtils responsive) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomLabel('email'.tr(), responsive),
          buildCustomTextField(
            controller: emailController,
            hintText: 'enter_email'.tr(),
            keyboardType: TextInputType.name,
            responsive: responsive,
            // onChanged: (_) => _onUsernameChanged(),
          ),
          const SizedBox(height: 2),
          buildCustomLabel('password'.tr(), responsive),
          buildCustomTextField(
            controller: passwordController,
            hintText: 'enter_password'.tr(),
            keyboardType: TextInputType.name,
            obscureText: !isPasswordVisible,
            responsive: responsive,
            suffixIcon: IconButton(
              icon: Icon(
                isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                color: accentColor.withOpacity(0.5),
              ),
              onPressed: () {
                setState(() {
                  isPasswordVisible = !isPasswordVisible;
                });
              },
            ),
          ),
          SizedBox(height: responsive.screenHeight * 0.01),
          buildButton(
            text: "login".tr(),
            onPressed: _login,
            isPrimary: true,
            width: responsive.screenWidth,
            responsive: responsive,
          ),
          SizedBox(height: responsive.screenHeight * 0.01),
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'not_user'.tr() + '?  ',
                    style: TextStyle(
                      color: const Color(0xFF676767),
                      fontSize: responsive.getTitleFontSize(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'register'.tr(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: responsive.getTitleFontSize(),
                      fontWeight: FontWeight.w500,
                      //decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.goToRegister,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
