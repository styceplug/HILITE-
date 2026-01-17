import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gift_bottom_modal.dart';
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
      body: GetBuilder<UserController>(
        builder: (controller) {
          var user = userController.othersProfile.value;

          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final isFollowing = userController.othersProfile.value!.isFollowed;

          var player = user.playerDetails;
          var club = user.clubDetails;
          var agent = user.agentDetails;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height10 * 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(Dimensions.width15, Dimensions.height30, Dimensions.width15, 0),
                  child: SizedBox(
                    // Ensure the Stack takes up the full width so centering is accurate
                    width: double.infinity,

                    // Set a height large enough to fit the Avatar/Buttons
                    child: Stack(
                      alignment: Alignment.topCenter,
                      // This forces the Avatar to the exact center
                      children: [
                        // 1. Back Button (Pinned Left)
                        Positioned(
                          left: 0,
                          // Remove default padding from BackButton to align perfectly with edge if needed
                          child: const BackButton(color: Colors.black),
                        ),

                        // 2. Profile Avatar (Centered by Stack alignment)
                        ProfileAvatar(avatarUrl: user.profilePicture),

                        // 3. Action Buttons (Pinned Right)
                        Positioned(
                          right: 0,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ℹ️ Info Button
                              InkWell(
                                onTap: () => _showProfileDetails(context, user),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: EdgeInsets.all(Dimensions.width10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.grey2,
                                  ),
                                  child: Icon(
                                    Icons.info_outline_rounded,
                                    color: AppColors.black,
                                    size:
                                        Dimensions
                                            .iconSize20, // Adjusted to your snippet
                                  ),
                                ),
                              ),

                              SizedBox(width: Dimensions.width10),

                              // 🎁 Gift Button
                              InkWell(
                                onTap: () {
                                  Get.bottomSheet(
                                    GiftSelectionBottomSheet(
                                      recipientId: user.id,
                                    ),
                                    isScrollControlled: true,
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.all(Dimensions.width10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.success,
                                  ),
                                  child: Icon(
                                    Iconsax.gift,
                                    color: AppColors.white,
                                    size: Dimensions.iconSize16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                /// 🧾 Name and Username
                Text(
                  user.role == 'club'
                      ? (user.clubDetails?.clubName ?? 'Unknown Club')
                      : (user.name.capitalizeFirst ?? 'Unknown'),
                  style: TextStyle(
                    fontSize: Dimensions.font20,
                    fontWeight: FontWeight.w700,
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

                /// 📊 Stats Row
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width100,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // if (user.role != 'fan')
                      _buildStat('Followers', '${user.followers}'),
                      _buildStat('Following', '${user.following}'),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height10),

                /// 🧾 Bio or Summary
                if (user.bio?.isNotEmpty ?? false)
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width30,
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

                SizedBox(height: Dimensions.height15),

                /// ⚽ Player Info
                if (user.role == 'player') ...[
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: Dimensions.height15,
                      left: Dimensions.width30,
                      right: Dimensions.width30,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildInfoTag('Position: ${player?.position ?? '-'}'),
                        _buildInfoTag('Height: ${player?.height ?? '-'}cm'),
                        _buildInfoTag('Weight: ${player?.weight ?? '-'}kg'),
                      ],
                    ),
                  ),
                ],

                /// 🏢 Club Info
                if (user.role == 'club') ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: Dimensions.height15,
                        left: Dimensions.width30,
                        right: Dimensions.width30,
                      ),
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
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: Dimensions.height15,
                        left: Dimensions.width30,
                        right: Dimensions.width30,
                      ),
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
                  ),
                ],

                /// 🔘 Follow & Message Buttons
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width40),
                  child: Row(
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
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                            vertical: Dimensions.height10,
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
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width20,
                            vertical: Dimensions.height10,
                          ),
                          backgroundColor: AppColors.grey4,
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius10,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTabItem(controller, 'video', 'Videos'),
                    _buildTabItem(controller, 'image', 'Photos'),
                    if (user.role == 'club')
                      _buildTabItem(controller, 'fixtures', 'Fixtures'),
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
                        .externalPostCache[controller.currentExternalPostType]!
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

                SizedBox(height: Dimensions.height50),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showProfileDetails(BuildContext context, UserModel user) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle Bar
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Header
            Row(
              children: [
                Icon(
                  Icons.person_pin_circle_outlined,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                const Text(
                  'About this Account',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- 1. General Info ---
                    _buildSectionTitle('General Information'),
                    _buildDetailRow(
                      Icons.person_outline,
                      'Full Name',
                      user.name,
                    ),
                    _buildDetailRow(
                      Icons.alternate_email,
                      'Username',
                      '@${user.username}',
                    ),
                    if (user.country.isNotEmpty)
                      _buildDetailRow(
                        Icons.flag_outlined,
                        'Country',
                        user.country,
                      ),
                    if (user.state.isNotEmpty)
                      _buildDetailRow(
                        Icons.location_city,
                        'State/Region',
                        user.state,
                      ),
                    _buildDetailRow(
                      Icons.calendar_today,
                      'Joined',
                      _formatDate(user.createdAt.toString()),
                    ),

                    const SizedBox(height: 15),

                    // --- 2. Role Specific Info ---

                    // PLAYER
                    if (user.role == 'player' &&
                        user.playerDetails != null) ...[
                      _buildSectionTitle('Player Details'),
                      _buildDetailRow(
                        Icons.sports_soccer,
                        'Position',
                        user.playerDetails?.position ?? '-',
                      ),
                      _buildDetailRow(
                        Icons.shield_outlined,
                        'Current Club',
                        user.playerDetails?.currentClub ?? '-',
                      ),
                      _buildDetailRow(
                        Icons.straighten,
                        'Height',
                        '${user.playerDetails?.height ?? '-'} cm',
                      ),
                      _buildDetailRow(
                        Icons.fitness_center,
                        'Weight',
                        '${user.playerDetails?.weight ?? '-'} kg',
                      ),
                      _buildDetailRow(
                        Icons.do_not_step,
                        'Preferred Foot',
                        user.playerDetails?.preferredFoot.capitalizeFirst ??
                            '-',
                      ),
                      _buildDetailRow(
                        Icons.cake,
                        'Date of Birth',
                        _formatDate(user.playerDetails?.dob.toString()),
                      ),
                    ],

                    // CLUB
                    if (user.role == 'club' && user.clubDetails != null) ...[
                      _buildSectionTitle('Club Details'),
                      _buildDetailRow(
                        Icons.shield,
                        'Club Name',
                        user.clubDetails?.clubName ?? user.name,
                      ),
                      _buildDetailRow(
                        Icons.category,
                        'Type',
                        user.clubDetails?.clubType.capitalizeFirst ?? '-',
                      ),
                      _buildDetailRow(
                        Icons.person,
                        'Manager',
                        user.clubDetails?.manager ?? '-',
                      ),
                      _buildDetailRow(
                        Icons.history,
                        'Founded',
                        user.clubDetails?.yearFounded ?? '-',
                      ),
                      // Removed 'League' since it is not in your ClubDetails model
                    ],

                    // AGENT
                    if (user.role == 'agent' && user.agentDetails != null) ...[
                      _buildSectionTitle('Agent Profile'),
                      _buildDetailRow(
                        Icons.business_center,
                        'Agency',
                        user.agentDetails?.agencyName ?? '-',
                      ),
                      // Fixed: Changed 'licenseId' to 'registrationId'
                      _buildDetailRow(
                        Icons.verified_user,
                        'Registration ID',
                        user.agentDetails?.registrationId ?? 'Not Listed',
                      ),
                      _buildDetailRow(
                        Icons.work_history,
                        'Experience',
                        user.agentDetails?.experience ?? '-',
                      ),
                    ],

                    const SizedBox(height: 15),
                    // Contact
                    _buildSectionTitle('Contact'),
                    _buildDetailRow(Icons.email_outlined, 'Email', user.email),
                    // if(user.number.isNotEmpty)
                    //   _buildDetailRow(Icons.phone_android, 'Phone', user.number),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 5),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[500],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return "${date.day}/${date.month}/${date.year}";
    } catch (e) {
      return dateStr;
    }
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
