import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../model/user_models.dart';
import '../../utils/Responsive_Utils.dart';
import '../../utils/colors.dart';
import '../../view model/auth_view_model.dart';
import '../../view model/maps_provider.dart';
import '../languages_screen.dart';
import '../login_or_register.dart';
import 'maps.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final authProvider = Provider.of<AuthViewModel>(context, listen: false);

  @override
  void initState() {
    // TODO: implement initState
    loadCurrentUser();
    super.initState();
  }

  UserModel? _currentUser;

  bool isLoading = false;
  loadCurrentUser() async {
    isLoading = true;
    setState(() {});
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    final currentUser = await authProvider.getUserByUid(currentUserId);
    setState(() {
      _currentUser = currentUser;
      isLoading = false;
    });
  }

  void _onQrScanned(UserModel currentUser, ResponsiveUtils responsive) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Let the column take minimal height
              children: [
                // const SizedBox(height: 20),
                SizedBox(
                  height: responsive.screenWidth * 0.5,
                  width: responsive.screenWidth * 0.5,
                  child: QrImageView(
                    data: currentUser.uid,
                    version: QrVersions.auto,
                    size: responsive.screenWidth * 0.5,
                    backgroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return const Scaffold(
        body: Center(child: Text("No User Found")),
      );
    }

    final responsive = ResponsiveUtils(context);
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(responsive),
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

  Widget _buildBackground(ResponsiveUtils responsive) {
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
              child: Stack(children: [
                Positioned(
                  left: 0,
                  top: 80,
                  right: 0,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "welcome_profile".tr(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: responsive.getAppBarFontSize() * 1.2,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ])),
        ),
        Expanded(child: Container(color: Colors.white)),
      ],
    );
  }

  Widget _buildLoginBox(
      AuthViewModel authProvider, ResponsiveUtils responsive) {
    return Container(
        width: responsive.screenWidth * 0.9,
        padding: const EdgeInsets.all(16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(
                color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
          ],
        ),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ListTile(
                leading: Container(
                  width: 42,
                  height: 42,
                  padding: const EdgeInsets.all(6),
                  decoration: ShapeDecoration(
                    color: senderBubbleColor,
                    shape: RoundedRectangleBorder(
                      side: const BorderSide(
                          width: 0.5, color: Color(0xFFE6E9EF)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child:
                      Icon(Icons.person, color: backgroundPageColor, size: 20),
                ),
                title: Text(_currentUser!.userName),
                subtitle: Text(_currentUser!.email),
                trailing: GestureDetector(
                    onTap: () {
                      _onQrScanned(_currentUser!, responsive);
                    },
                    child: Icon(
                      Icons.qr_code,
                      color: accentColor,
                    )),
              ),
              const SizedBox(height: 40),
              buildProfileOption(
                  title: "my_location".tr(),
                  subtitle: "track_location".tr(),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeNotifierProvider(
                          create: (_) => MapsProvider()..initialize(),
                          child: const Maps(),
                        ),
                      ),
                    );
                  }),
              const SizedBox(height: 8),
              const Divider(
                  // color: Colors.grey,
                  ),
              buildProfileOption(
                title: "app_languages".tr(),
                subtitle: "change_language".tr(),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LanguageSelectionScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),
              InkWell(
                onTap: () async {
                  await authProvider.logout();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const LoginOrRegisterScreen(),
                    ),
                  );
                },
                child: Container(
                  width: responsive.screenWidth * 0.8,
                  height: responsive.screenHeight * 0.06,
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.screenWidth * 0.02,
                    vertical: responsive.screenHeight * 0.01,
                  ),
                  decoration: ShapeDecoration(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(width: 0.7, color: accentColor),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_outlined,
                        color: accentColor,
                        size: responsive.scaleFont(18),
                      ),
                      SizedBox(width: responsive.screenWidth * 0.02),
                      Text(
                        "logout".tr(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: responsive.getBodyFontSize(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ]));
  }

  Widget buildProfileOption({
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    final responsive = ResponsiveUtils(context);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: responsive.screenHeight * 0.01),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: const Color(0xFF171717),
                      fontSize: responsive.getTitleFontSize(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: responsive.screenHeight * 0.005),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: const Color(0xFF676767),
                      fontSize: responsive.getBodyFontSize(),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: responsive.screenWidth * 0.02),
            Icon(
              Icons.arrow_forward_ios,
              size: responsive.scaleFont(16),
              color: Colors.grey,
            )
          ],
        ),
      ),
    );
  }
}
