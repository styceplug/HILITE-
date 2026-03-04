import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/notification_controller.dart';
import 'package:hilite/controllers/post_controller.dart';
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
import '../../../utils/others.dart';
import '../../../widgets/post_grid_shimmer.dart';
import '../../../widgets/profile_avatar.dart';
import '../../../widgets/reels_video_item.dart';
import '../../others/others_profile.dart';
import '../../others/relationship_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserController userController = Get.find<UserController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

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
          onRefresh: () async {
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
                      Obx(() {
                        final count = notificationController.unreadCount.value;
                        return InkWell(
                          onTap: () {
                            Get.toNamed(AppRoutes.notificationsScreen);
                          },
                          child: Stack(
                            children: [
                              Icon(
                                CupertinoIcons.bell,
                                size: Dimensions.iconSize24,
                              ),
                              if (count > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      count > 99 ? '99+' : '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }),

                      MyProfileAvatar(
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
                  SizedBox(height: Dimensions.height20),

                  if (user.role == 'club') ...[
                    Text(
                      club?.clubName ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  if (user.role == 'agent') ...[
                    Text(
                      user.agentDetails!.agencyName,
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

                  if (user.role == 'fan' || user.role == 'player') ...[
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],

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
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Text(
                      user.bio ?? 'No Bio Yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Dimensions.font13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.black.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height10),

                  /// 📊 Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Posts', '${user.posts}', 'posts'),
                      _divider(),
                      _buildStat('Followers', '${user.followers}', 'followers'),
                      _divider(),
                      _buildStat('Following', '${user.following}', 'following'),
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
                              _buildInfoTag(
                                'Year Founded: ${user.clubDetails?.yearFounded}',
                              ),
                              SizedBox(width: Dimensions.width20),
                              _buildInfoTag(
                                'Club Type: ${club?.clubType.capitalizeFirst ?? '-'}',
                              ),
                              SizedBox(width: Dimensions.width20),
                              _buildInfoTag('Manager: ${club?.manager ?? '-'}'),
                              SizedBox(width: Dimensions.width20),

                              _buildInfoTag('Country: ${user.country ?? '-'}'),
                              SizedBox(width: Dimensions.width20),

                              _buildInfoTag('State: ${user.state ?? '-'}'),
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
                    Padding(
                      padding: EdgeInsets.only(bottom: Dimensions.height15),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildInfoTag(
                              'Agency: ${agent?.agencyName ?? '-'}',
                            ),
                            SizedBox(width: Dimensions.width10),
                            _buildInfoTag(
                              'Experience: ${agent?.experience ?? '-'}',
                            ),
                            SizedBox(width: Dimensions.width10),
                            _buildInfoTag(
                              'Licence Number: ${agent?.registrationId}',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  /// ✏️ Edit Profile Button
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Edit Profile',
                              onPressed: () {
                                Get.toNamed(AppRoutes.editProfileScreen);
                              },
                              backgroundColor: AppColors.primary,
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius10,
                              ),
                            ),
                          ),

                          if (user.role != 'fan') ...[
                            SizedBox(width: Dimensions.width10),
                            CustomButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.uploadContent);
                              },
                              text: 'Add Post',
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius10,
                              ),
                              backgroundColor: AppColors.white,
                              borderColor: AppColors.primary,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: Dimensions.height10),
                      if (user.role == 'club' || user.role == 'agent') ...[
                        Row(
                          children: [
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
                            if (user.role == 'club') ...[
                              SizedBox(width: Dimensions.width20),
                              Expanded(
                                child: CustomButton(
                                  onPressed: () {
                                    Get.toNamed(
                                      AppRoutes.createCompetitionScreen,
                                    );
                                  },
                                  text: 'Create Competition',
                                  borderRadius: BorderRadius.circular(
                                    Dimensions.radius10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(width: Dimensions.width10),
                      ],
                    ],
                  ),

                  SizedBox(height: Dimensions.height30),

                  Builder(
                    builder: (context) {
                      if (controller.isFirstLoad &&
                          controller.postCache.values.every((l) => l.isEmpty)) {
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
    ];

    PostController postController = Get.find<PostController>();

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
              final videoOnlyList =
                  allPosts.where((p) => p.type == 'video').toList();
              final converted =
                  videoOnlyList.map((p) => personalToPostModel(p)).toList();
              final videoIndex = videoOnlyList.indexOf(post);

              if (videoIndex != -1) {
                Get.to(
                  () => ProfileReelsPlayer(
                    videos: converted,
                    initialIndex: videoIndex,
                  ),
                );
              }
            } else {
              Get.to(() => ProfileImageViewer(imageUrl: post.mediaUrl!));
            }
          },
          onLongPress: () {
            if (post.id == null) return;

            Get.dialog(
              AlertDialog(
                title: Text('Delete Post'),
                content: Text(
                  'Are you sure you want to delete this post? This action cannot be undone',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      postController.deleteUserPost(post.id!, post.type!);
                    },
                    child: Text('Delete'),
                  ),
                ],
              ),
            );
          },
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

  /// 🧩 Clickable Stat Widget
  Widget _buildStat(String label, String value, String type) {
    return InkWell(
      onTap: () {
        // Navigate to the new RelationshipScreen
        Get.to(
          () => RelationshipScreen(title: label, type: type, targetId: null),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Column(
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
                color: Colors.grey[700], // Slight grey to indicate clickable
              ),
            ),
          ],
        ),
      ),
    );
  }

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

class ProfileImageViewer extends StatelessWidget {
  final String imageUrl;

  const ProfileImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      // 1. Allows image to extend behind the AppBar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // 2. Make AppBar transparent
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            // Optional: Backdrop for back button visibility
            shape: BoxShape.circle,
          ),
          child: const BackButton(color: Colors.white),
        ),
      ),
      body: GestureDetector(
        onTap: () => Get.back(),
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4,
          child: Center(
            child: Hero(
              tag: imageUrl,
              child: Image.network(
                imageUrl,
                // 3. Force image to take full screen dimensions
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,

                // 4. Choose your fit:
                // BoxFit.contain = Shows FULL image (may have black bars)
                // BoxFit.cover   = Fills screen (WILL CROP edges)
                fit: BoxFit.contain,

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.error, color: Colors.white, size: 50),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
