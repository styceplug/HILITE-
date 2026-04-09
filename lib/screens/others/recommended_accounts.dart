import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';

import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';

import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/reels_video_item.dart';
import '../home/pages/profile_screen.dart';

class RecommendedAccountsScreen extends StatefulWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  State<RecommendedAccountsScreen> createState() =>
      _RecommendedAccountsScreenState();
}

class _RecommendedAccountsScreenState extends State<RecommendedAccountsScreen> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController searchController = TextEditingController();

  static const List<String> _nigerianStates = [
    'Abia',
    'Adamawa',
    'Akwa Ibom',
    'Anambra',
    'Bauchi',
    'Bayelsa',
    'Benue',
    'Borno',
    'Cross River',
    'Delta',
    'Ebonyi',
    'Edo',
    'Ekiti',
    'Enugu',
    'FCT',
    'Gombe',
    'Imo',
    'Jigawa',
    'Kaduna',
    'Kano',
    'Katsina',
    'Kebbi',
    'Kogi',
    'Kwara',
    'Lagos',
    'Nasarawa',
    'Niger',
    'Ogun',
    'Ondo',
    'Osun',
    'Oyo',
    'Plateau',
    'Rivers',
    'Sokoto',
    'Taraba',
    'Yobe',
    'Zamfara',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.recommendedUsers.isEmpty) {
        userController.getRecommendedUsers();
      } else {
        if (userController.filteredUsers.isEmpty) {
          userController.filteredUsers.assignAll(
            userController.recommendedUsers,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Accounts, Images, Videos
      child: Scaffold(
        backgroundColor: AppColors.bgColor,
        appBar: CustomAppbar(
          title: 'Search Hilite',
          leadingIcon: const BackButton(),
        ),
        body: Column(
          children: [
            // --- Search & Filters ---
            _buildSearchHeader(),

            // --- Tab Bar (Only visible when searching) ---
            Obx(
              () =>
                  userController.searchQuery.value.isNotEmpty
                      ? Container(
                        color: Colors.white,
                        child: TabBar(
                          labelColor: AppColors.primary,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: AppColors.primary,
                          tabs: const [
                            Tab(text: 'Accounts'),
                            Tab(text: 'Images'),
                            Tab(text: 'Videos'),
                          ],
                        ),
                      )
                      : const SizedBox.shrink(),
            ),

            // --- Results ---
            Expanded(
              child: Obx(() {
                // Show Loading State
                if (userController.isSearching.value) {
                  return Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }

                // Discovery Mode (No search term)
                if (userController.searchQuery.value.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => userController.getRecommendedUsers(),
                    child: _buildUserList(userController.filteredUsers),
                  );
                }

                // Global Search Mode
                return TabBarView(
                  children: [
                    _buildUserList(userController.searchUsers),
                    _buildImageGrid(userController.searchImages),
                    _buildVideoGrid(userController.searchVideos),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserList(List<UserModel> users) {
    final visibleUsers =
        users
            .where((candidate) => !userController.isCurrentUser(candidate.id))
            .toList();

    if (visibleUsers.isEmpty)
      return _buildEmptyState(
        icon: Icons.person,
        title: "No users found",
        message: "",
      );
    return ListView.builder(
      padding: EdgeInsets.all(Dimensions.width20),
      itemCount: visibleUsers.length,
      itemBuilder: (context, index) => _buildAccountCard(visibleUsers[index]),
    );
  }

  Widget _buildImageGrid(List<dynamic> images) {
    if (images.isEmpty)
      return _buildEmptyState(
        icon: Icons.image_search,
        title: 'Not Found',
        message: 'Search Query did not return any image',
      );

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final PostModel post =
            images[index] as PostModel; // ✅ Cast to PostModel
        final img = post.image?.url ?? ''; // ✅ Access property directly

        return InkWell(
          onTap: () {
            Get.to(() => ProfileImageViewer(imageUrl: img));
          },
          child: Image.network(
            img,
            fit: BoxFit.cover,
            errorBuilder:
                (_, __, ___) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
          ),
        );
      },
    );
  }

  Widget _buildVideoGrid(List<dynamic> videos) {
    if (videos.isEmpty)
      return _buildEmptyState(
        icon: Icons.videocam_outlined,
        title: "No videos",
        message: "Try searching for highlights",
      );

    return GridView.builder(
      padding: EdgeInsets.all(Dimensions.width10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: videos.length,
      itemBuilder:
          (context, index) => InkWell(
            onTap: () {
              List<PostModel> searchPosts =
                  videos.map((e) => e as PostModel).toList();
              print('tapped');
              Get.to(
                () => ProfileReelsPlayer(
                  videos: searchPosts,
                  initialIndex: index,
                  authorProfile: userController.othersProfile.value,
                ),
              );
            },
            child: _buildVideoCard(videos[index]),
          ),
    );
  }

  Widget _buildVideoCard(dynamic videoData) {
    // Cast videoData to PostModel (since that's what it actually is)
    final PostModel post = videoData as PostModel;

    // Access the video property directly from the PostModel object
    final video = post.video;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.black12,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail with error handling
          Image.network(
            video?.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(
                  Icons.video_library,
                  size: 40,
                  color: Colors.grey,
                ),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),

          // Play Icon
          Center(
            child: Icon(
              Icons.play_circle_fill,
              color: Colors.white.withOpacity(0.8),
              size: 40,
            ),
          ),

          // Title and Duration
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video?.title ?? post.text ?? 'Highlight',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                if (video?.duration != null)
                  Text(
                    "${video!.duration?.toStringAsFixed(0)}s",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomTextField(
            controller: searchController,
            maxLines: 1,
            hintText: 'Search people, highlights, or clubs...',
            prefixIcon: Icons.search,
            suffixIcon: Obx(
              () =>
                  userController.searchQuery.value.isNotEmpty
                      ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          searchController.clear();
                          userController.onSearchChanged('');
                        },
                      )
                      : const SizedBox.shrink(),
            ),
            onChanged: (value) => userController.onSearchChanged(value),
          ),

          // Only show role filters for Accounts
          Obx(
            () =>
                userController.searchQuery.value.isEmpty
                    ? Column(
                      children: [
                        SizedBox(height: Dimensions.height15),
                        _buildFilterChips(),
                      ],
                    )
                    : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // --- 1. Role Filter: Fans ---
            _buildFilterChip(
              label: 'Fans',
              icon: Icons.person_outline,
              isSelected: userController.selectedRole.value == 'fan',
              onTap: () {
                if (userController.selectedRole.value == 'fan') {
                  userController.selectedRole.value = '';
                } else {
                  userController.selectedRole.value = 'fan';
                  userController.selectedPosition.value = '';
                }
                userController.applyFilters();
              },
            ),

            SizedBox(width: Dimensions.width10),

            // --- 2. Role Filter: Players ---
            _buildFilterChip(
              label: 'Players',
              icon: Icons.sports_soccer,
              isSelected: userController.selectedRole.value == 'player',
              onTap: () {
                if (userController.selectedRole.value == 'player') {
                  userController.selectedRole.value = '';
                  userController.selectedPosition.value = '';
                } else {
                  userController.selectedRole.value = 'player';
                }
                userController.applyFilters();
              },
            ),

            // --- CONDITIONAL: Position Filter ---
            // This is now placed immediately after "Players"
            if (userController.selectedRole.value == 'player') ...[
              SizedBox(width: Dimensions.width10),
              // Animate the appearance of the position chip
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: _buildFilterChip(
                  label:
                      userController.selectedPosition.value.isEmpty
                          ? 'Position'
                          : userController.selectedPosition.value,
                  icon: Icons.location_on,
                  isSelected: userController.selectedPosition.value.isNotEmpty,
                  onTap: () {
                    _showPositionBottomSheet(context);
                  },
                ),
              ),

              SizedBox(width: Dimensions.width10),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                builder: (context, value, child) {
                  return Transform.scale(scale: value, child: child);
                },
                child: _buildFilterChip(
                  label:
                      userController.selectedAgeRange.value.isEmpty
                          ? 'Age'
                          : userController.selectedAgeRange.value,
                  icon: Icons.cake_outlined,
                  isSelected: userController.selectedAgeRange.value.isNotEmpty,
                  onTap: () => _showAgeBottomSheet(context),
                ),
              ),
            ],
            SizedBox(width: Dimensions.width10),

            _buildFilterChip(
              label:
                  userController.selectedRegion.value.isEmpty
                      ? 'Region'
                      : userController.selectedRegion.value,
              icon: Icons.location_city,
              isSelected: userController.selectedRegion.value.isNotEmpty,
              onTap: () => _showRegionBottomSheet(context),
            ),

            SizedBox(width: Dimensions.width10),

            // --- 3. Role Filter: Agents ---
            _buildFilterChip(
              label: 'Agents',
              icon: Icons.business_center,
              isSelected: userController.selectedRole.value == 'agent',
              onTap: () {
                if (userController.selectedRole.value == 'agent') {
                  userController.selectedRole.value = '';
                } else {
                  userController.selectedRole.value = 'agent';
                  userController.selectedPosition.value = '';
                }
                userController.applyFilters();
              },
            ),

            SizedBox(width: Dimensions.width10),

            // --- 4. Role Filter: Clubs ---
            _buildFilterChip(
              label: 'Clubs',
              icon: Icons.shield,
              isSelected: userController.selectedRole.value == 'club',
              onTap: () {
                if (userController.selectedRole.value == 'club') {
                  userController.selectedRole.value = '';
                } else {
                  userController.selectedRole.value = 'club';
                  userController.selectedPosition.value = '';
                }
                userController.applyFilters();
              },
            ),
          ],
        ),
      );
    });
  }

  void _showRegionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Region',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Obx(() {
                      final hasRegion =
                          userController.selectedRegion.value.isNotEmpty;
                      return hasRegion
                          ? TextButton.icon(
                            onPressed: () {
                              userController.selectedRegion.value = '';
                              userController.applyFilters();
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.clear, size: 18),
                            label: const Text('Clear'),
                          )
                          : const SizedBox.shrink();
                    }),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _nigerianStates.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final region = _nigerianStates[index];
                      return Obx(() {
                        final selected =
                            userController.selectedRegion.value == region;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: CircleAvatar(
                            backgroundColor:
                                selected
                                    ? AppColors.primary.withOpacity(.15)
                                    : Colors.grey[100],
                            child: Icon(
                              Icons.location_city,
                              color:
                                  selected
                                      ? AppColors.primary
                                      : Colors.grey[700],
                            ),
                          ),
                          title: Text(
                            region,
                            style: TextStyle(
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w600,
                            ),
                          ),
                          trailing:
                              selected
                                  ? Icon(
                                    Icons.check_circle,
                                    color: AppColors.primary,
                                  )
                                  : const Icon(Icons.chevron_right),
                          onTap: () {
                            userController.selectedRegion.value = region;
                            userController.applyFilters();
                            Navigator.pop(context);
                          },
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAgeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final ranges = const ['U18', '18-20', '21-29', '30-34', '35+'];

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select Age Range',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  Obx(() {
                    final has =
                        userController.selectedAgeRange.value.isNotEmpty;
                    return has
                        ? TextButton.icon(
                          onPressed: () {
                            userController.selectedAgeRange.value = '';
                            userController.applyFilters();
                            Navigator.pop(context);
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear'),
                        )
                        : const SizedBox.shrink();
                  }),
                ],
              ),
              const SizedBox(height: 8),

              ...ranges.map((r) {
                return Obx(() {
                  final selected = userController.selectedAgeRange.value == r;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor:
                          selected
                              ? AppColors.primary.withOpacity(.15)
                              : Colors.grey[100],
                      child: Icon(
                        Icons.cake_outlined,
                        color: selected ? AppColors.primary : Colors.grey[700],
                      ),
                    ),
                    title: Text(
                      r,
                      style: TextStyle(
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                    trailing:
                        selected
                            ? Icon(Icons.check_circle, color: AppColors.primary)
                            : const Icon(Icons.chevron_right),
                    onTap: () {
                      userController.selectedAgeRange.value = r;
                      userController.applyFilters();
                      Navigator.pop(context);
                    },
                  );
                });
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width15,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[100],
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            SizedBox(width: Dimensions.width5),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight: FontWeight.w600,
                fontSize: Dimensions.font14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Enhanced Account Card
  Widget _buildAccountCard(UserModel user) {
    return Obx(() {
      final currentUser = _findCurrentUser(user.id) ?? user;
      final isFollowed = currentUser.isFollowed;
      final isFollowBusy = userController.followBusyUserIds.contains(user.id);

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: Dimensions.height15),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          elevation: 2,
          shadowColor: Colors.black.withOpacity(0.08),
          child: InkWell(
            onTap:
                () => Get.toNamed(
                  AppRoutes.othersProfileScreen,
                  arguments: {'targetId': currentUser.id},
                ),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.width15),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          currentUser.profilePicture.isNotEmpty
                              ? currentUser.profilePicture
                              : 'https://placehold.net/avatar-2.png',
                          height: 65,
                          width: 65,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return Container(
                              height: 65,
                              width: 65,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.person,
                                color: AppColors.primary,
                                size: 32,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: Dimensions.width15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                currentUser.displayName,
                                style: TextStyle(
                                  fontSize: Dimensions.font17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[900],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: Dimensions.width5),
                            _buildVerifiedBadge(currentUser.role),
                          ],
                        ),
                        SizedBox(height: Dimensions.height5),
                        if (currentUser.bio != null &&
                            currentUser.bio!.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(
                              bottom: Dimensions.height10,
                            ),
                            child: Text(
                              currentUser.bio!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: Dimensions.font14,
                                color: Colors.grey[600],
                                height: 1.3,
                              ),
                            ),
                          ),
                        SizedBox(height: Dimensions.height10),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildActionButton(
                                label:
                                    isFollowBusy
                                        ? 'Please wait'
                                        : (isFollowed ? 'Following' : 'Follow'),
                                icon:
                                    isFollowBusy
                                        ? Icons.hourglass_top_rounded
                                        : (isFollowed
                                            ? Icons.check
                                            : Icons.add),
                                isPrimary: !isFollowed,
                                isBusy: isFollowBusy,
                                onTap:
                                    isFollowBusy
                                        ? null
                                        : () {
                                          if (isFollowed) {
                                            userController.unfollowUser(
                                              currentUser.id,
                                            );
                                          } else {
                                            userController.followUser(
                                              currentUser.id,
                                            );
                                          }
                                        },
                              ),
                            ),
                            SizedBox(width: Dimensions.width10),
                            _buildIconButton(
                              icon: Icons.more_horiz,
                              onTap:
                                  () => _showOptionsBottomSheet(
                                    context,
                                    currentUser,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // Verified Badge
  Widget _buildVerifiedBadge(String role) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: AppColors.primary),
          const SizedBox(width: 4),
          Text(
            role.capitalizeFirst ?? '',
            style: TextStyle(
              fontSize: 11,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Action Button
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required bool isPrimary,
    required VoidCallback? onTap,
    bool isBusy = false,
  }) {
    return Material(
      color:
          isPrimary
              ? (isBusy
                  ? AppColors.primary.withOpacity(0.75)
                  : AppColors.primary)
              : Colors.grey[100],
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: isBusy ? null : onTap,
        borderRadius: BorderRadius.circular(25),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isPrimary ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : Colors.grey[800],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  UserModel? _findCurrentUser(String userId) {
    for (final collection in [
      userController.filteredUsers,
      userController.searchUsers,
      userController.recommendedUsers,
      userController.searchResults,
    ]) {
      final index = collection.indexWhere((user) => user.id == userId);
      if (index != -1) {
        return collection[index];
      }
    }

    return null;
  }

  // Icon Button
  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.grey[100],
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 20, color: Colors.grey[700]),
        ),
      ),
    );
  }

  // Empty State
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          SizedBox(height: Dimensions.height20),
          Text(
            title,
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Text(
            message,
            style: TextStyle(
              fontSize: Dimensions.font14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Info Dialog
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  'About Recommendations',
                  style: TextStyle(fontSize: Dimensions.font20),
                ),
              ],
            ),
            content: const Text(
              'Accounts are suggested based on your interests and connections. Your account may also be suggested to people you may know.',
              style: TextStyle(height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
    );
  }

  // Position Bottom Sheet
  void _showPositionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => PositionsBottomSheet(
            onSelect: (position) {
              userController.selectedPosition.value = position;
              userController.applyFilters();
            },
            currentPosition: userController.selectedPosition.value,
          ),
    );
  }

  // Options Bottom Sheet
  void _showOptionsBottomSheet(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Iconsax.gift),
                  title: const Text('Gift User'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add report functionality
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.block_outlined, color: Colors.red),
                  title: const Text('Block User'),
                  onTap: () {
                    Navigator.pop(context);
                    userController.blockUser(user.id);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.report_outlined),
                  title: const Text('Report User'),
                  onTap: () {
                    Navigator.pop(context);
                    // Add report functionality
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
    );
  }
}

class PositionsBottomSheet extends StatelessWidget {
  final Function(String) onSelect;
  final String currentPosition;

  const PositionsBottomSheet({
    super.key,
    required this.onSelect,
    this.currentPosition = '',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          MediaQuery.of(context).size.height * 0.85, // Takes up 85% of screen
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag Handle
          Container(
            width: 40,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Position',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                if (currentPosition.isNotEmpty)
                  TextButton.icon(
                    onPressed: () {
                      onSelect('');
                      Get.back();
                    },
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Clear'),
                  ),
              ],
            ),
          ),

          // THE FIELD
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50), // Grass Green
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.green[800]!, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    _buildFieldMarkings(),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Attackers
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PositionNode('LW', currentPosition, onSelect),
                              Container(
                                margin: const EdgeInsets.only(bottom: 20),
                                child: _PositionNode(
                                  'ST',
                                  currentPosition,
                                  onSelect,
                                ),
                              ),
                              _PositionNode('RW', currentPosition, onSelect),
                            ],
                          ),

                          // Midfield (Upper)
                          _PositionNode('CAM', currentPosition, onSelect),

                          // Midfield (Lower)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PositionNode('CM', currentPosition, onSelect),
                              _PositionNode('CDM', currentPosition, onSelect),
                            ],
                          ),

                          // Defenders
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _PositionNode('LB', currentPosition, onSelect),
                              _PositionNode('CB', currentPosition, onSelect),
                              _PositionNode('RB', currentPosition, onSelect),
                            ],
                          ),

                          // Goalkeeper
                          _PositionNode('GK', currentPosition, onSelect),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldMarkings() {
    return Stack(
      children: [
        // Center Circle
        Center(
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
        ),
        // Center Line
        Center(
          child: Container(
            height: 2,
            width: double.infinity,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
        // Goal Area (Bottom)
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),
        // Goal Area (Top)
        Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PositionNode extends StatelessWidget {
  final String label;
  final String currentSelection;
  final Function(String) onTap;

  const _PositionNode(this.label, this.currentSelection, this.onTap);

  @override
  Widget build(BuildContext context) {
    final isSelected = label == currentSelection;

    return GestureDetector(
      onTap: () {
        onTap(label);
        Get.back();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.85),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.transparent,
                width: isSelected ? 3 : 0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isSelected ? AppColors.primary : Colors.grey[800],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
