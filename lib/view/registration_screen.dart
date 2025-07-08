import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/country_model.dart';
import '../services/country_service.dart';
import '../utils/Responsive_Utils.dart';
import '../utils/colors.dart';
import '../utils/textFields_utils.dart';
import '../view model/auth_view_model.dart';
import 'bottom_nav_screen.dart';
import 'navigation/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? goToLogin;
  const RegisterScreen({super.key, required this.goToLogin});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final countryController = TextEditingController();
  final usernameController = TextEditingController();
  final mobileController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isPasswordVisible = false;
  List<Country> _countryList = [];
  Country? _selectedCountry;
  bool _isCountryLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  void _fetchCountries() async {
    setState(() => _isCountryLoading = true);
    try {
      final countries = await CountryService().fetchCountries();
      setState(() {
        _countryList = countries;
        _isCountryLoading = false;
      });
    } catch (e) {
      setState(() => _isCountryLoading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error fetching countries")));
    }
  }

  void _register() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    final authProvider = Provider.of<AuthViewModel>(context, listen: false);
    await authProvider.registerWithDetails(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      userName: usernameController.text.trim(),
      country: _selectedCountry?.name ?? '',
      mobile: mobileController.text.trim(),
      context: context,
    );

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
              child: _buildRegisterBox(authProvider, responsive),
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
          ),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }

  Widget _buildRegisterBox(
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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          buildCustomLabel('email'.tr(), responsive),
          buildCustomTextField(
            controller: emailController,
            hintText: 'enter_email'.tr(),
            keyboardType: TextInputType.name,
            responsive: responsive,
          ),
          // buildCustomLabel('Country', responsive),
          // buildCustomTextField(
          //   controller: countryController,
          //   hintText: 'Enter your Country',
          //   keyboardType: TextInputType.name,
          //   responsive: responsive,
          //   // onChanged: (_) => _onUsernameChanged(),
          // ),
          buildCustomLabel('country'.tr(), responsive),
          buildCustomDropdownField<Country>(
            value: _selectedCountry,
            hintText: 'select_country'.tr(),
            isLoading: _isCountryLoading,
            responsive: responsive,
            items: _countryList.map((country) {
              return DropdownMenuItem<Country>(
                value: country,
                child: Text(country.name, overflow: TextOverflow.ellipsis),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() => _selectedCountry = newValue);
            },
          ),

          buildCustomLabel('username'.tr(), responsive),
          buildCustomTextField(
            controller: usernameController,
            hintText: 'enter_username'.tr(),
            keyboardType: TextInputType.name,
            responsive: responsive,
          ),
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
          buildCustomLabel('confirm_password'.tr(), responsive),
          buildCustomTextField(
            controller: confirmPasswordController,
            hintText: 'reenter_password'.tr(),
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
          buildCustomLabel('mobile'.tr(), responsive),
          buildCustomTextField(
            controller: mobileController,
            hintText: 'enter_mobile'.tr(),
            keyboardType: TextInputType.name,
            responsive: responsive,
          ),
          SizedBox(height: responsive.screenHeight * 0.01),
          buildButton(
            text: "register".tr(),
            onPressed: _register,
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
                    text: 'already_user'.tr() + '?   ',
                    style: TextStyle(
                      color: const Color(0xFF676767),
                      fontSize: responsive.getTitleFontSize(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'login'.tr(),
                    style: TextStyle(
                      color: textColor,
                      fontSize: responsive.getTitleFontSize(),
                      fontWeight: FontWeight.w500,
                      //decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = widget.goToLogin,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
