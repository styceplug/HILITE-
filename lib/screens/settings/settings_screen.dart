import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  AuthController authController = Get.find<AuthController>();
  UserController userController = Get.find<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
      appBar: CustomAppbar(
        title: "Settings & Privacy",
        centerTitle: false,
        backgroundColor: const Color(0xFF030A1B),
        leadingIcon: const Icon(Iconsax.setting, color: Colors.white),
      ),
      body: Container(
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: Dimensions.height10),

              // --- ACCOUNT SECTION ---
              _buildSectionHeader("Account"),
              SizedBox(height: Dimensions.height10),

              // Only showing Edit Profile for players based on your logic
              // (Though you might want to open this to agents/clubs too!)
              if(userController.user.value?.role == 'player')
                settingTile(
                  icon: Iconsax.user,
                  title: "Edit Profile",
                  onTap: () {
                    Get.toNamed(AppRoutes.editProfileScreen);
                  },
                ),
              settingTile(
                icon: Iconsax.lock,
                title: "Change Password",
                onTap: () {
                  Get.toNamed(AppRoutes.forgotPasswordScreen);
                },
              ),
              settingTile(
                icon: Iconsax.profile_tick,
                title: "Verify Account",
                onTap: () {
                  CustomSnackBar.showToast(message: 'Verification not available to you yet');
                },
              ),
              settingTile(
                icon: Iconsax.link,
                title: "Referral Program",
                onTap: () {
                  Get.toNamed(AppRoutes.referralScreen);
                },
              ),
              settingTile(
                  icon: Iconsax.wallet,
                  title: 'Wallet',
                  onTap: () {
                    Get.toNamed(AppRoutes.walletScreen);
                  }
              ),
              settingTile(
                icon: Iconsax.bookmark,
                title: "Bookmarked Posts",
                onTap: () {
                  Get.toNamed(AppRoutes.bookmarksScreen);
                },
              ),

              // Club specific settings
              if(userController.user.value?.role == 'club')...[
                settingTile(
                  icon: Icons.sports_soccer, // Swapped to a more relevant icon
                  title: "My Trials",
                  onTap: () {
                    Get.toNamed(AppRoutes.myTrialsScreen);
                  },
                ),
                settingTile(
                  icon: Iconsax.cup,
                  title: "My Competitions",
                  onTap: () {
                    Get.toNamed(AppRoutes.myCompetitionsScreen);
                  },
                ),
              ],

              SizedBox(height: Dimensions.height30),

              // --- PREFERENCES SECTION ---
              _buildSectionHeader("Preferences"),
              SizedBox(height: Dimensions.height10),

              switchTile(
                icon: Iconsax.notification,
                title: "Push Notifications",
                value: notificationsEnabled,
                onChanged: (v) => setState(() => notificationsEnabled = v),
              ),

              SizedBox(height: Dimensions.height30),

              // --- SUPPORT SECTION ---
              _buildSectionHeader("Support"),
              SizedBox(height: Dimensions.height10),

              settingTile(
                icon: Iconsax.message_question,
                title: "Help & Support",
                onTap: () {},
              ),
              settingTile(
                icon: Iconsax.security_safe,
                title: "Privacy Policy",
                onTap: () {},
              ),
              settingTile(
                icon: Iconsax.info_circle,
                title: "About HiLite",
                onTap: () {},
              ),

              SizedBox(height: Dimensions.height40),

              // --- LOGOUT BUTTON ---
              CustomButton(
                text: "Log Out",
                onPressed: () {
                  authController.logout();
                  Get.offAllNamed(AppRoutes.loginScreen);
                },
                // Deep red for dark theme consistency
                backgroundColor: const Color(0xFFDC2626),
                borderRadius: BorderRadius.circular(12),
              ),
              SizedBox(height: Dimensions.height50),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for consistent section headers
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: Dimensions.width10, bottom: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: Dimensions.font13,
          fontWeight: FontWeight.w700,
          color: Colors.white.withOpacity(0.5),
          letterSpacing: 1.2, // Gives it that premium OS feel
        ),
      ),
    );
  }

  Widget settingTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: Dimensions.height15,
          horizontal: Dimensions.width15,
        ),
        margin: EdgeInsets.only(bottom: Dimensions.height10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05), // Dark theme glassmorphism
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
            SizedBox(width: Dimensions.width15),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const Spacer(),
            Icon(Iconsax.arrow_right_3, color: Colors.white.withOpacity(0.3), size: 18),
          ],
        ),
      ),
    );
  }

  Widget switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: Dimensions.height10, // Slightly reduced vertical padding to accommodate switch height
        horizontal: Dimensions.width15,
      ),
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          SizedBox(width: Dimensions.width15),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font15,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          CupertinoSwitch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.buttonColor,
            trackColor: Colors.white.withOpacity(0.1),
          ),
        ],
      ),
    );
  }
}