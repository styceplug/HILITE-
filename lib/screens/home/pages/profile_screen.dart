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
import '../../../models/post_model.dart';
import '../../../widgets/post_grid_shimmer.dart';
import '../../../widgets/profile_avatar.dart';
import '../../../widgets/reels_video_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserController userController = Get.find<UserController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getPersonalPosts('video');
      // userController.loadCachedUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        print('this has been rebuilt');
        var user = controller.user.value;

        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        var player = user.playerDetails;
        var club = user.clubDetails;
        var agent = user.agentDetails;

        print(user.bio);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ()async{
            userController.getPersonalPosts('video');
            userController.getPersonalPosts('image');
          },
          child: Container(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width20,
                vertical: Dimensions.height50,
              ),
              child: Column(
                children: [
                  SizedBox(height: Dimensions.height20),

                  /// 🔝 Header Icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.notificationsScreen);
                        },
                        child: Icon(
                          CupertinoIcons.bell,
                          size: Dimensions.iconSize30,
                        ),
                      ),

                      ProfileAvatar(
                        avatarUrl: user.profilePicture,
                        onImageSelected: (XFile file) {
                          userController.uploadProfilePicture(file);
                        },
                      ),

                      InkWell(
                        onTap: () => Get.toNamed(AppRoutes.settingsScreen),
                        child: Icon(
                          Iconsax.more_circle,
                          size: Dimensions.iconSize24,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Dimensions.height30),

                  /// 🧑‍💼 Profile Avatar
                  SizedBox(height: Dimensions.height20),

                  /// 🧾 Name & Role
                  if (user.role == 'club')
                    Text(
                      club?.clubName ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (user.role != 'club')
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
                  Row(
                    children: [
                      if (user.role == 'club' || user.role == 'agent') ...[

                        CustomButton(
                          text: 'Create Trial',
                          onPressed: () {
                            Get.toNamed(AppRoutes.createTrialScreen);
                          },
                          backgroundColor: AppColors.secondary,
                          borderColor: AppColors.primary,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius10,
                          ),
                        ),
                      ],

                      Expanded(
                        child: CustomButton(
                          text: 'Edit Profile',
                          onPressed: () {
                            Get.toNamed(AppRoutes.editProfileScreen);
                          },
                          backgroundColor: AppColors.primary,
                          borderRadius: BorderRadius.circular(Dimensions.radius10),
                        ),
                      ),
                      SizedBox(width: Dimensions.width10,),
                      CustomButton(
                        onPressed: () {
                          Get.toNamed(AppRoutes.uploadContent);
                        },
                        text: 'Add Post',
                        borderRadius: BorderRadius.circular(Dimensions.radius10),
                        backgroundColor: AppColors.white,
                        borderColor: AppColors.primary,
                      ),
                    ],
                  ),

                  SizedBox(height: Dimensions.height30),
                  /*Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                    child: Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width20,vertical: Dimensions.height10
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.grey4
                          )
                        ),
                        child: Text(
                          "Posts",
                          style: TextStyle(
                            fontSize: Dimensions.font18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                      ),
                    ),
                  ),*/

                  Builder(
                    builder: (context) {
                      // Check if EVERYTHING is loading (optional, depends on your loading logic)
                      if (controller.isFirstLoad && controller.postCache.values.every((l) => l.isEmpty)) {
                        return const PostGridShimmer();
                      }

                      return _buildContentGrid(controller);
                    },
                  ),


                  SizedBox(height: Dimensions.height30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(UserController controller, String type, String label) {
    bool isSelected = controller.currentPostType == type;
    return InkWell(
      onTap: () => controller.getPersonalPosts(type),
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

  Widget _buildContentGrid(UserController controller) {
    // 1. Merge all cached lists into one
    List<PersonalPostModel> allPosts = [
      ...?controller.postCache['video'],
      ...?controller.postCache['image'],
      ...?controller.postCache['text'], // Assuming you cache text posts too
    ];

    // 2. Sort by Date (Newest first)
    // Ensure your PersonalPostModel has a DateTime 'createdAt'
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allPosts.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: Dimensions.height30),
        child: const Text("No posts yet."),
      );
    }

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
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];

        // We use the post's own type, not a controller state
        final postType = post.type;

        return GestureDetector(
          onTap: () {
            if (postType == 'video') {
              // ⚠️ Crucial: The video player usually needs a clean list of ONLY videos.
              // We filter the list on the fly so the user can scroll up/down in the reels player.
              final videoOnlyList = allPosts.where((p) => p.type == 'video').toList();
              final videoIndex = videoOnlyList.indexOf(post);

              if (videoIndex != -1) {
                Get.to(
                      () => ProfileReelsPlayer(
                    videos: videoOnlyList,
                    initialIndex: videoIndex,
                  ),
                );
              }
            } else {
              // Handle navigation for Images/Text if needed
              // Get.to(() => PostDetailScreen(post: post));
            }
          },
          // Pass the specific post's type to the tile builder
          child: _buildTileItem(post, postType ?? 'image'),
        );
      },
    );
  }

  Widget _buildTileItem(PersonalPostModel post, String type) {
    // 1. TEXT
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
    }
    // 2. IMAGE
    else if (type == 'image') {
      // 🛡️ Safety Check: If url is null or empty, show a placeholder instead of crashing
      if (post.mediaUrl == null || post.mediaUrl!.isEmpty) {
        return Container(
          color: AppColors.grey2,
          child: const Icon(Icons.broken_image, color: Colors.grey),
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
    }
    // 3. VIDEO
    else {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.black),
          // If you have a thumbnail, render it here safely
          if (post.thumbnail != null && post.thumbnail!.isNotEmpty)
            Image.network(post.thumbnail!, fit: BoxFit.cover),

          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
          ),
        ],
      );
    }
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
