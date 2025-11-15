import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hilite/models/user_model.dart';
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


class _ProfileScreenState extends State<ProfileScreen> {
  final userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // userController.getUserProfile();
      // userController.loadCachedUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        final user = controller.user.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final player = user.playerDetails;
        final club = user.clubDetails;
        final agent = user.agentDetails;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height50,
          ),
          child: Column(
            children: [
              SizedBox(height: Dimensions.height20),

              /// 🔝 Header Icons
              Row(
                children: [
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.recommendedAccountsScreen),
                    child: Icon(Iconsax.people, size: Dimensions.iconSize24),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: () => Get.toNamed(AppRoutes.settingsScreen),
                    child: Icon(Iconsax.more_circle, size: Dimensions.iconSize24),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height30),

              /// 🧑‍💼 Profile Avatar
              ProfileAvatar(
                avatarUrl: user.profilePicture,
                onImageSelected: (XFile file) {
                  userController.uploadProfilePicture(file);
                },
              ),
              SizedBox(height: Dimensions.height20),

              /// 🧾 Name & Role
              if(user.role=='club')
              Text(
                club?.clubName ?? '',
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if(user.role != 'club')
                Text(
                  user.name,
                  style: TextStyle(
                    fontSize: Dimensions.font18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              Text(
                '@${user.username}'.toLowerCase(),
                style: TextStyle(
                  fontSize: Dimensions.font14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.black.withOpacity(0.7),
                ),
              ),
              SizedBox(height: Dimensions.height10),

              /// 📖 Bio
              if (user.bio!.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  child: Text(
                    user.bio ?? '',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Dimensions.font13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.black.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ),

              SizedBox(height: Dimensions.height20),



              /// 📊 Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (user.role != 'fan')
                    _buildStat('Posts', '${user.posts}'),
                  if (user.role != 'fan') _divider(),
                  _buildStat('Followers', '${user.followers}'),
                  _divider(),
                  _buildStat('Following', '${user.following}'),
                ],
              ),

              SizedBox(height: Dimensions.height30),

              /// ⚽ Player Info
              if (user.role == 'player') ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoTag('Position: ${player?.position ?? '-'}'),
                    _buildInfoTag('Height: ${player?.height ?? '-'}cm'),
                    _buildInfoTag('Weight: ${player?.weight ?? '-'}kg'),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
              ],

              /// 🏢 Club Info
              if (user.role == 'club') ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildInfoTag('Handler\'s Name: ${user.name ?? '-'}'),
                          SizedBox(width: Dimensions.width20),
                          _buildInfoTag('Club Type: ${club?.clubType ?? '-'}'),
                          SizedBox(width: Dimensions.width20),
                          _buildInfoTag('Manager: ${club?.manager ?? '-'}'),
                          SizedBox(width: Dimensions.width20),
                          _buildInfoTag('Founded: ${club?.yearFounded ?? '-'}'),
                          SizedBox(width: Dimensions.width20),

                        ],
                      ),
                      SizedBox(height: Dimensions.width20),

                    ],
                  ),
                ),
              ],

              /// 🤝 Agent Info
              if (user.role == 'agent') ...[
                _buildInfoTag('Agency: ${agent?.agencyName ?? '-'}'),
                SizedBox(height: Dimensions.height5),
                _buildInfoTag('Experience: ${agent?.experience ?? '-'}'),
                SizedBox(height: Dimensions.height20),
              ],

              /// ✏️ Edit Profile Button
              if (user.role != 'fan')
                CustomButton(
                  text: 'Edit Profile',
                  onPressed: () {
                    Get.toNamed(AppRoutes.editProfileScreen);
                  },
                  backgroundColor: AppColors.primary,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),

              SizedBox(height: Dimensions.height30),
              Divider(color: AppColors.grey4),
              SizedBox(height: Dimensions.height20),

              /// 📦 Placeholder Boxes (for future content)
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
      },
    );
  }

  /// 🧩 Stat Widget
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

  /// ┆ Divider
  Widget _divider() => Container(
    width: 0.5,
    height: Dimensions.height50,
    color: AppColors.grey4,
  );

  /// 🔖 Info Tag
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

  /// 📦 Placeholder Box
  Widget _buildBox() => Container(
    height: Dimensions.height100 * 2,
    width: Dimensions.screenWidth / 3.5,
    decoration: BoxDecoration(
      color: AppColors.grey2,
      borderRadius: BorderRadius.circular(Dimensions.radius10),
    ),
  );
}