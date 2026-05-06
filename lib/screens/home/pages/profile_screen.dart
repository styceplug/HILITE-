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
import 'package:skeletonizer/skeletonizer.dart';

import '../../../controllers/user_controller.dart';
import '../../../models/post_model.dart';
import '../../../utils/others.dart';
import '../../../widgets/post_grid_shimmer.dart';
import '../../../widgets/profile_avatar.dart';
import '../../../widgets/reels_video_item.dart';
import '../../others/bookmarks_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserController userController = Get.find<UserController>();
  PostController postController = Get.find<PostController>();
  NotificationController notificationController =
      Get.find<NotificationController>();

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getPersonalPosts('video');
      // userController.loadCachedUser();
      postController.getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserController>(
      builder: (controller) {
        var user = controller.user.value;

        if (user == null) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        final bool isProRole = (user.role == 'club' || user.role == 'agent');
        final List<String> profileTabs =
            isProRole
                ? ['Squad', 'Highlights', 'Saved', 'Info']
                : ['Highlights', 'Saved'];

        if (_selectedTabIndex >= profileTabs.length) {
          _selectedTabIndex = 0;
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            userController.getPersonalPosts('video');
            userController.getPersonalPosts('image');
            postController.getBookmarks();
            CustomSnackBar.showToast(message: 'Refreshed');
          },
          child: SizedBox(
            height: Dimensions.screenHeight,
            width: Dimensions.screenWidth,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: Dimensions.height50),
              child: Column(
                children: [
                  SizedBox(height: Dimensions.height20),

                  /// 🔝 Header Icons
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Obx(() {
                          final count =
                              notificationController.unreadCount.value;
                          return InkWell(
                            onTap:
                                () =>
                                    Get.toNamed(AppRoutes.notificationsScreen),
                            child: Stack(
                              children: [
                                Icon(
                                  CupertinoIcons.bell,
                                  size: Dimensions.iconSize30,
                                  color: AppColors.white,
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
                                          fontSize: 9,
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
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),

                  /// 🏷️ Name display logic
                  if (user.role == 'club') ...[
                    Text(
                      user.clubDetails?.clubName ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                  if (user.role == 'agent') ...[
                    Text(
                      user.agentDetails?.agencyName ?? '',
                      style: TextStyle(
                        fontSize: Dimensions.font22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],
                  if (user.role == 'fan' || user.role == 'player') ...[
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: Dimensions.font22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.white,
                      ),
                    ),
                  ],

                  /// 📖 Bio
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height10,
                    ),
                    child: Text(
                      user.bio ?? 'No Bio Yet',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.white.withOpacity(0.8),
                        height: 1.4,
                      ),
                    ),
                  ),

                  SizedBox(height: Dimensions.height10),

                  /// ✏️ Edit Profile Button
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Row(
                      children: [
                        CustomButton(
                          text: 'Edit Page',
                          icon: Iconsax.edit,
                          onPressed:
                              () => Get.toNamed(AppRoutes.editProfileScreen),
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width30,
                            vertical: Dimensions.height15,
                          ),
                          backgroundColor: AppColors.buttonColor,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius10,
                          ),
                        ),
                        SizedBox(width: Dimensions.width20),
                        Expanded(
                          child: CustomButton(
                            onPressed: () {
                              // Get.toNamed(AppRoutes.uploadContent);
                            },
                            text: 'Preview Page',
                            icon: Icons.visibility,
                            borderRadius: BorderRadius.circular(
                              Dimensions.radius10,
                            ),
                            backgroundColor: AppColors.white.withOpacity(0.1),
                            borderColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height20),

                  /// 📊 Stats
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        const Spacer(),
                        Text(
                          user.followers.toSocialString(),
                          style: TextStyle(
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: Dimensions.width5),
                        Text(
                          'Followers',
                          style: TextStyle(
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),

                        _divider(),
                        const Spacer(),

                        Text(
                          user.following.toSocialString(),
                          style: TextStyle(
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                        SizedBox(width: Dimensions.width5),
                        Text(
                          'Following',
                          style: TextStyle(
                            fontSize: Dimensions.font17,
                            fontWeight: FontWeight.w500,
                            color: AppColors.white.withOpacity(0.8),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),

                  SizedBox(height: Dimensions.height30),

                  /// 📑 DYNAMIC TAB BAR
                  _buildCustomTabBar(profileTabs),

                  SizedBox(height: Dimensions.height20),

                  /// 🖼️ TAB CONTENT RENDERER
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                    ),
                    child: _buildSelectedTabContent(
                      controller,
                      profileTabs[_selectedTabIndex],
                    ),
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

  Widget _buildCustomTabBar(List<String> tabs) {
    return Container(
      width: Dimensions.screenWidth,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.white.withOpacity(0.1), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(tabs.length, (index) {
          bool isSelected = _selectedTabIndex == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTabIndex = index),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: Dimensions.height10,
                    ),
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: Dimensions.font14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color:
                            isSelected
                                ? AppColors.white
                                : AppColors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? Dimensions.width40 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.buttonColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedTabContent(
    UserController controller,
    String currentTab,
  ) {
    if (currentTab == 'Highlights') {
      if (controller.isFirstLoad &&
          controller.postCache.values.every((l) => l.isEmpty)) {
        // --- CALLED NEW SKELETONIZER LOADER HERE ---
        return _buildSkeletonGrid();
      }
      return _buildContentGrid(controller);
    }else if (currentTab == 'Saved') {
      return GetBuilder<PostController>(
        builder: (postCtrl) {
          if (postCtrl.bookmarkList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: Dimensions.height30),
                  Icon(
                    Iconsax.save_2,
                    size: Dimensions.iconSize30 * 4,
                    color: AppColors.textColor.withOpacity(0.1),
                  ),
                  SizedBox(height: Dimensions.height10),
                  const Text(
                    'No saved items yet.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
              childAspectRatio: 3 / 4, // Match highlights aspect ratio
            ),
            itemCount: postCtrl.bookmarkList.length,
            itemBuilder: (context, index) {
              final post = postCtrl.bookmarkList[index];
              return GestureDetector(
                onTap: () {
                  Get.to(() => BookmarkPlayerScreen(
                    posts: postCtrl.bookmarkList,
                    initialIndex: index,
                  ));
                },
                child: _buildBookmarkTileItem(post), // New builder for PostModel
              );
            },
          );
        },
      );
    } else if (currentTab == 'Squad' || currentTab == 'Info') {
      return Center(
        child: Text(
          'No $currentTab data yet.',
          style: const TextStyle(color: Colors.white70),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  // --- NEW: SKELETONIZER GRID BUILDER ---
  Widget _buildSkeletonGrid() {
    return Skeletonizer(
      enabled: true,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          childAspectRatio: 3 / 4,
        ),
        itemCount: 6,
        // Show 6 fake items while loading
        itemBuilder: (context, index) {
          return Container(
            color: Colors.grey[800],
            child: const Center(
              child: Icon(
                Icons.play_circle_outline,
                color: Colors.white30,
                size: 30,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookmarkTileItem(PostModel post) {
    Widget tileContent;

    if (post.type == 'video') {
      tileContent = Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.black),
          if (post.video?.thumbnailUrl != null && post.video!.thumbnailUrl!.isNotEmpty)
            Image.network(post.video!.thumbnailUrl!, fit: BoxFit.cover),
          const Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white70,
              size: 30,
            ),
          ),
        ],
      );
    } else if (post.type == 'image') {
      tileContent = Image.network(
        post.image?.url ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: AppColors.grey2.withOpacity(0.2),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        ),
      );
    } else {
      tileContent = Container(
        padding: const EdgeInsets.all(8),
        color: AppColors.grey2.withOpacity(0.2),
        child: Center(
          child: Text(
            post.text ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Apply the exact same rounded corners as the Highlights tab
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: tileContent,
    );
  }

  Widget _buildContentGrid(UserController controller) {
    List<PersonalPostModel> allPosts = [
      ...?controller.postCache['video'],
      ...?controller.postCache['image'],
    ];

    PostController postController = Get.find<PostController>();
    allPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    if (allPosts.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(top: Dimensions.height30),
        child: Column(
          children: [
            Icon(
              Iconsax.image,
              size: Dimensions.iconSize30 * 4,
              color: AppColors.white.withOpacity(0.2),
            ),
            SizedBox(height: Dimensions.height10),
            CustomButton(
              onPressed: () {
                Get.toNamed(AppRoutes.uploadContent);
              },
              text: 'Create your first post',
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 3 / 4,
      ),
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];
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
                title: const Text('Delete Post'),
                content: const Text(
                  'Are you sure you want to delete this post? This action cannot be undone.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                      postController.deleteUserPost(post.id!, post.type!);
                    },
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Colors.red),
                    ),
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
    Widget tileContent;

    if (type == 'image') {
      if (post.mediaUrl == null || post.mediaUrl!.isEmpty) {
        tileContent = Container(
          color: AppColors.grey2.withOpacity(0.2),
          child: const Icon(Icons.broken_image, color: Colors.grey),
        );
      } else {
        tileContent = Container(
          decoration: BoxDecoration(
            color: AppColors.grey2.withOpacity(0.2),
            image: DecorationImage(
              image: NetworkImage(post.mediaUrl!),
              fit: BoxFit.cover,
            ),
          ),
        );
      }
    } else {
      // VIDEO TILE
      tileContent = Stack(
        fit: StackFit.expand,
        children: [
          Container(color: AppColors.black),

          if (post.thumbnail != null && post.thumbnail!.isNotEmpty)
            Image.network(post.thumbnail!, fit: BoxFit.cover),

          const Center(
            child: Icon(
              Icons.play_circle_outline_rounded,
              color: Colors.white70,
              size: 30,
            ),
          ),

          // Duration Badge
          if (post.duration != null)
            Positioned(
              bottom: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  post.duration!.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: tileContent,
    );
  }

  Widget _divider() => Container(
    width: 0.5,
    height: Dimensions.height20,
    color: AppColors.white.withOpacity(0.3),
  );
}

extension SocialFormat on num {
  String toSocialString() {
    if (this >= 1000000) {
      double res = this / 1000000;
      return '${res.toStringAsFixed(res % 1 == 0 ? 0 : 1)}m';
    } else if (this >= 1000) {
      double res = this / 1000;
      return '${res.toStringAsFixed(res % 1 == 0 ? 0 : 1)}k';
    } else {
      return toString();
    }
  }
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
