import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';
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
      appBar: CustomAppbar(
        title: "Settings & Privacy",
        centerTitle: false,
        leadingIcon: Icon(Iconsax.setting),
      ),
      body: Container(
        height: Dimensions.screenHeight,
        width: Dimensions.screenWidth,
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Account section
            Text(
              "Account",
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height10),
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
              onTap: () {},
            ),

            SizedBox(height: Dimensions.height30),

            // Preferences section
            Text(
              "Preferences",
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4,
              ),
            ),
            SizedBox(height: Dimensions.height10),

            switchTile(
              icon: Iconsax.notification,
              title: "Push Notifications",
              value: notificationsEnabled,
              onChanged: (v) => setState(() => notificationsEnabled = v),
            ),
            
            SizedBox(height: Dimensions.height30),

            // Support section
            Text(
              "Support",
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey4,
              ),
            ),
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

            const Spacer(),

            // Logout
            CustomButton(
              text: "Log Out",
              onPressed: () {
                authController.logout();
                Get.offAllNamed(AppRoutes.loginScreen);
              },
              backgroundColor: AppColors.error,
              borderRadius: BorderRadius.circular(Dimensions.radius10),
            ),
            SizedBox(height: Dimensions.height50),
          ],
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
          color: AppColors.grey2.withOpacity(0.4),
          borderRadius: BorderRadius.circular(Dimensions.radius10),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            SizedBox(width: Dimensions.width10),
            Text(
              title,
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(Iconsax.arrow_right_3, color: AppColors.grey4),
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
        vertical: Dimensions.height15,
        horizontal: Dimensions.width15,
      ),
      margin: EdgeInsets.only(bottom: Dimensions.height10),
      decoration: BoxDecoration(
        color: AppColors.grey2.withOpacity(0.4),
        borderRadius: BorderRadius.circular(Dimensions.radius10),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          SizedBox(width: Dimensions.width10),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}