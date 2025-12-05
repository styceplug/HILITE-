import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/post_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/post_grid_shimmer.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/reels_video_item.dart';

class OthersProfileScreen extends StatefulWidget {
  const OthersProfileScreen({super.key});

  @override
  State<OthersProfileScreen> createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfileScreen> {
  UserController userController = Get.find<UserController>();
  String? targetId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.clearExternalCache();

      targetId = Get.arguments?['targetId'];
      if (targetId != null) {
        userController.getOthersProfile(targetId!);
        userController.getExternalUserPosts(targetId!, 'video');
      } else {
        CustomSnackBar.failure(message: 'User not found');
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: const BackButton()),
      body: GetBuilder<UserController>(
        builder: (controller) {
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
                    // if (user.role != 'fan')
                      _buildStat('Followers', '${user.followers}'),
                    _divider(),
                    _buildStat('Following', '${user.following}'),
                  ],
                ),
                SizedBox(height: Dimensions.height20),

                /// 🧾 Bio or Summary
                if (user.bio?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
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
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius10,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),
                ],

                /// 🏢 Club Info
                if (user.role == 'club') ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height20),
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
                        _buildInfoTag(
                          'Experience: ${agent?.experience ?? '-'}',
                        ),
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
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius10,
                        ),
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
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius10,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: Dimensions.height40),

                /// 📑 TABS SECTION (Videos, Photos, Posts)
                if (user.role != 'fan') ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTabItem(controller, 'video', 'Videos'),
                      _buildTabItem(controller, 'image', 'Photos'),
                      _buildTabItem(controller, 'text', 'Posts'),
                    ],
                  ),
                  SizedBox(height: Dimensions.height20),

                  /// 🖼️ CONTENT GRID
                  Builder(
                    builder: (context) {
                      // 1. Loading + Empty = Shimmer
                      if (controller.isExternalPostsLoading &&
                          controller
                              .externalPostCache[controller
                                  .currentExternalPostType]!
                              .isEmpty) {
                        return const PostGridShimmer(); // Reuse your shimmer
                      }

                      // 2. Not Loading + Empty = No Data Text
                      if (controller
                          .externalPostCache[controller
                              .currentExternalPostType]!
                          .isEmpty) {
                        return Center(
                          child: Text(
                            "No ${controller.currentExternalPostType} found.",
                          ),
                        );
                      }

                      // 3. Data Exists = Grid
                      return _buildContentGrid(controller);
                    },
                  ),
                ],

                SizedBox(height: Dimensions.height50),
              ],
            ),
          );
        },
      ),
    );
  }

  /// 🔘 Tab Helper
  Widget _buildTabItem(UserController controller, String type, String label) {
    bool isSelected = controller.currentExternalPostType == type;
    return InkWell(
      onTap: () {
        if (targetId != null) {
          controller.getExternalUserPosts(targetId!, type);
        }
      },
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: Dimensions.font16,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppColors.primary : AppColors.grey4,
            ),
          ),
          SizedBox(height: 5),
          if (isSelected)
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }

  /// 📱 Grid Helper
  Widget _buildContentGrid(UserController controller) {
    var posts =
        controller.externalPostCache[controller.currentExternalPostType] ?? [];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
        childAspectRatio: 1,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        var post = posts[index];
        return GestureDetector(
          onTap: () {
            if (controller.currentExternalPostType == 'video') {
              Get.to(
                () => ProfileReelsPlayer(videos: posts, initialIndex: index),
              );
            }
          },
          child: _buildTileItem(post, controller.currentExternalPostType),
        );
      },
    );
  }

  /// 🧱 Tile Helper (Copy of your Personal Profile Logic)
  Widget _buildTileItem(PersonalPostModel post, String type) {
    if (type == 'text') {
      return Container(
        padding: const EdgeInsets.all(8),
        color: AppColors.grey2,
        child: Center(
          child: Text(
            post.text ?? '',
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: Dimensions.font12),
          ),
        ),
      );
    } else if (type == 'image') {
      if (post.mediaUrl == null || post.mediaUrl!.isEmpty) {
        return Container(
          color: AppColors.grey2,
          child: const Icon(Icons.broken_image),
        );
      }
      return Container(
        decoration: BoxDecoration(
          color: AppColors.grey2,
          image: DecorationImage(
            image: NetworkImage(post.mediaUrl!),
            fit: BoxFit.cover,
          ),
        ),
      );
    } else {
      // Video
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.black),
          if (post.thumbnail != null && post.thumbnail!.isNotEmpty)
            Image.network(post.thumbnail!, fit: BoxFit.cover),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
          ),
        ],
      );
    }
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
}
