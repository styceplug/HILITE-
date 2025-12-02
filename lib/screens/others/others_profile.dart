import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/profile_avatar.dart';

class OthersProfileScreen extends StatefulWidget {
  const OthersProfileScreen({super.key});

  @override
  State<OthersProfileScreen> createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfileScreen> {
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      var targetId = Get.arguments?['targetId'];
      if (targetId != null) {
        userController.getOthersProfile(targetId);
      } else {
        CustomSnackBar.failure(message: 'No user ID provided');
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: Obx(() {
        var user = userController.othersProfile.value;

        final isFollowing = userController.othersProfile.value!.isFollowed;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        var player = user.playerDetails;
        var club = user.clubDetails;
        var agent = user.agentDetails;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// 👤 Profile Picture
              ProfileAvatar(avatarUrl: user.profilePicture),
              SizedBox(height: Dimensions.height20),

              /// 🧾 Name and Username
              Text(
                user.role == 'club'
                    ? (user.clubDetails?.clubName ?? 'Unknown Club')
                    : (user.name.capitalizeFirst ?? 'Unknown'),
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

              SizedBox(height: Dimensions.height20),

              /// 📊 Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  if (user.role != 'fan')
                  _buildStat('Followers', '${user.followers}'),
                  _divider(),
                  _buildStat('Following', '${user.following}'),
                ],
              ),
              SizedBox(height: Dimensions.height20),

              /// 🧾 Bio or Summary
              if (user.bio?.isNotEmpty ?? false)
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

              /// ⚽ Player Info
              if (user.role == 'player') ...[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoTag('Position: ${player?.position ?? '-'}'),
                        _buildInfoTag('Height: ${player?.height ?? '-'}cm'),
                        _buildInfoTag('Weight: ${player?.weight ?? '-'}kg'),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomButton(
                      text: 'Gift Creator',
                      textStyle: TextStyle(
                        color: AppColors.white,
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                      onPressed: () {
                        CustomSnackBar.processing(
                          message: 'Direct messaging coming soon!',
                        );
                      },
                      backgroundColor: AppColors.primary,
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),

                  ],
                ),
                SizedBox(height: Dimensions.height20),
              ],

              /// 🏢 Club Info
              if (user.role == 'club') ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoTag('Account Name: ${user.name ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                      _buildInfoTag('Club Type: ${club?.clubType ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                      _buildInfoTag('Manager: ${club?.manager ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                      _buildInfoTag('Founded: ${club?.yearFounded ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                    ],
                  ),
                ),
              ],

              /// 🤝 Agent Info
              if (user.role == 'agent') ...[
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildInfoTag('Agency: ${agent?.agencyName ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                      _buildInfoTag('Experience: ${agent?.experience ?? '-'}'),
                      SizedBox(width: Dimensions.height5),
                    ],
                  ),
                ),
              ],

              // SizedBox(height: Dimensions.height20),

              /// 🔘 Follow & Message Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: CustomButton(
                      text: isFollowing ? 'Unfollow' : 'Follow',
                      textStyle: TextStyle(
                        color: AppColors.white,
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                      onPressed:
                          () =>
                              !isFollowing
                                  ? userController.followUser(user.id)
                                  : userController.unfollowUser(user.id),
                      backgroundColor: AppColors.primary,
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                  ),
                  SizedBox(width: Dimensions.width20),
                  Expanded(
                    child: CustomButton(
                      text: 'Message',
                      textStyle: TextStyle(
                        color: AppColors.black,
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w500,
                      ),
                      onPressed: () {
                        CustomSnackBar.showToast(
                          message: 'Direct messaging coming soon!',
                        );
                      },
                      backgroundColor: AppColors.grey4,
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                    ),
                  ),
                ],
              ),


              SizedBox(height: Dimensions.height40),

              /// 🧭 Tabs Placeholder (Videos, Images, Trials)
              if (user.role != 'fan') _buildTabSection(),
            ],
          ),
        );
      }),
    );
  }

  /// 🧩 Stats Box
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
          color: AppColors.black.withOpacity(0.7),
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

  /// 📂 Placeholder for future tab content (videos, images, trials)
  Widget _buildTabSection() => Container(
    margin: EdgeInsets.only(top: Dimensions.height20),
    padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(Dimensions.radius10),
      border: Border.all(color: AppColors.grey3),
    ),
    child: Column(
      children: [
        Text(
          'Content Preview',
          style: TextStyle(
            fontSize: Dimensions.font15,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: Dimensions.height10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            Icon(Icons.video_library_outlined),
            Icon(Icons.image_outlined),
            Icon(Icons.sports_soccer_outlined),
          ],
        ),
        SizedBox(height: Dimensions.height10),
        Text(
          'Videos • Images • Trials (Coming Soon)',
          style: TextStyle(
            fontSize: Dimensions.font13,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),
  );
}
