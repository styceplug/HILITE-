import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart';

import '../../../controllers/user_controller.dart';
import '../../../widgets/profile_avatar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    // Load profile once screen is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getUserProfile();
    });
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final user = userController.user.value;
      if (user == null) {
        return const Center(child: CircularProgressIndicator());
      }

      final player = user.playerDetails;

      return SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height50,
        ),
        child: Column(
          children: [
            SizedBox(height: Dimensions.height20),

            // Top row icons
            Row(
              children: [
                Icon(Iconsax.people, size: Dimensions.iconSize24),
                const Spacer(),
                Icon(Iconsax.edit_2, size: Dimensions.iconSize24),
                SizedBox(width: Dimensions.width20),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.settingsScreen),
                  child: Icon(Iconsax.more_circle, size: Dimensions.iconSize24),
                ),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // Profile picture
            ProfileAvatar(
              avatarUrl: userController.user.value?.profilePicture,
              onImageSelected: (XFile file) {
                userController.uploadProfilePicture(file);
              },
            ),
            SizedBox(height: Dimensions.height20),

            // Name
            Text(
              user.name,
              style: TextStyle(
                fontSize: Dimensions.font18,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Role
            Text(
              user.role.capitalizeFirst ?? '',
              style: TextStyle(
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Dimensions.height5),

            // Bio
            if (player?.bio != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                child: Text(
                  player!.bio,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.error,
                  ),
                ),
              ),

            SizedBox(height: Dimensions.height10),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Posts', user.posts.toString()),
                _divider(),
                _buildStat('Followers', user.followers.toString()),
                _divider(),
                _buildStat('Following', user.following.toString()),
              ],
            ),
            SizedBox(height: Dimensions.height20),

            // Attributes for player
            if (user.role == 'player')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildInfoTag('Position: ${player?.position ?? '-'}'),
                  _buildInfoTag('Height: ${player?.height ?? '-'}cm'),
                  _buildInfoTag('Weight: ${player?.weight ?? '-'}kg'),
                ],
              ),

            SizedBox(height: Dimensions.height20),

            // Edit button
            if (user.role == 'player')
            CustomButton(
              text: 'Edit Profile',
              onPressed: () {
                Get.toNamed(AppRoutes.editProfileScreen);
              },
              backgroundColor: AppColors.primary,
              borderRadius: BorderRadius.circular(Dimensions.radius10),
            ),

            SizedBox(height: Dimensions.height20),
            Divider(color: AppColors.grey4),
            SizedBox(height: Dimensions.height20),

            // Placeholder boxes (posts, highlights, etc.)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildBox(),
                _buildBox(),
                _buildBox(),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStat(String label, String value) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: Dimensions.font22,
          fontWeight: FontWeight.w600,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: Dimensions.font14,
          fontWeight: FontWeight.w400,
        ),
      ),
    ],
  );

  Widget _divider() => Container(
    width: 0.5,
    height: Dimensions.height50,
    color: AppColors.grey4,
  );

  Widget _buildInfoTag(String text) => Container(
    padding: EdgeInsets.symmetric(
      horizontal: Dimensions.width10,
      vertical: Dimensions.height5,
    ),
    decoration: BoxDecoration(
      color: AppColors.grey2,
      borderRadius: BorderRadius.circular(Dimensions.radius10),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Dimensions.font13,
        fontWeight: FontWeight.w500,
        color: AppColors.black,
      ),
    ),
  );

  Widget _buildBox() => Container(
    height: Dimensions.height100 * 2,
    width: Dimensions.screenWidth / 3.5,
    decoration: BoxDecoration(
      color: AppColors.grey2,
      borderRadius: BorderRadius.circular(Dimensions.radius10),
    ),
  );
}