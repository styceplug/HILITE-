import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/screens/home/pages/profile_screen.dart';
import 'package:hilite/screens/others/others_profile.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';
import '../../controllers/post_controller.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/country_state_dropdown.dart';
import '../../widgets/reels_video_item.dart';
import 'dart:ui';

class RecommendedAccountsScreen extends StatefulWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  State<RecommendedAccountsScreen> createState() => _RecommendedAccountsScreenState();
}

class _RecommendedAccountsScreenState extends State<RecommendedAccountsScreen> {
  final UserController userController = Get.find<UserController>();
  final PostController postController = Get.find<PostController>();
  final TextEditingController searchController = TextEditingController();

  String _selectedRole = '';
  List<String> _selectedPositions = [];
  String _selectedAgeRange = '';
  String _selectedFoot = '';
  String _selectedAvailability = '';
  String _selectedExperience = '';

  String? _selectedCountry;
  String? _selectedState;
  String? _selectedLga;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.recommendedUsers.isEmpty) userController.getRecommendedUsers();
      if (postController.posts.isEmpty) postController.loadRecommendedPosts('video');
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B),
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        title: 'Discover',
        leadingIcon: const BackButton(color: Colors.white),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterRow(),
          Expanded(
            child: Obx(() {
              final isSearchActive = userController.searchQuery.value.isNotEmpty;

              if (isSearchActive) {
                return _buildSearchMode();
              } else {
                return _buildDiscoverMode();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoverMode() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1))),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              tabs: const [
                Tab(text: 'For You'),
                Tab(text: 'Trending'),
                Tab(text: 'Recently Added'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              physics: const BouncingScrollPhysics(),
              children: [
                _buildForYouTab(),
                _buildTrendingTab(),
                _buildRecentlyAddedTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForYouTab() {
    return Obx(() {
      final List<UserModel> displayUsers = userController.filteredUsers;
      final List<PostModel> displayPosts = postController.posts;

      if (displayUsers.isEmpty && displayPosts.isEmpty) {
        return _buildEmptyState(Icons.explore, "Nothing found", "Adjust your filters to see more content.");
      }

      return RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1F2937),
        onRefresh: () async {
          userController.getRecommendedUsers();
          postController.loadRecommendedPosts('video');
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (displayUsers.isNotEmpty) ...[
                _buildSectionHeader("Recommended Talents", onTap: () {
                  Get.to(() => SeeAllUsersScreen(title: "Recommended Talents", users: displayUsers));
                }),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemCount: displayUsers.length,
                    itemBuilder: (context, index) {
                      if (userController.isCurrentUser(displayUsers[index].id)) return const SizedBox.shrink();
                      return _buildPremiumProfileCard(displayUsers[index]);
                    },
                  ),
                ),
                const SizedBox(height: 35),
              ],
              if (displayPosts.isNotEmpty) ...[
                _buildSectionHeader("Highlights For You"),
                const SizedBox(height: 12),
                _buildHorizontalVideoList(displayPosts),
                const SizedBox(height: 40),
              ],
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTrendingTab() {
    return Obx(() {
      final List<PostModel> trending = List.from(postController.posts);
      trending.sort((a, b) => (b.score ?? 0).compareTo(a.score ?? 0));

      if (trending.isEmpty) return _buildEmptyState(Icons.trending_up, "No Trending Posts", "Check back later.");

      return RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1F2937),
        onRefresh: () async => postController.loadRecommendedPosts('video'),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _buildVideoGrid(trending),
        ),
      );
    });
  }

  Widget _buildRecentlyAddedTab() {
    return Obx(() {
      final List<PostModel> recent = List.from(postController.posts);
      recent.sort((a, b) => (b.createdAt ?? DateTime.now()).compareTo(a.createdAt ?? DateTime.now()));

      if (recent.isEmpty) return _buildEmptyState(Icons.new_releases, "No Recent Posts", "Check back later.");

      return RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1F2937),
        onRefresh: () async => postController.loadRecommendedPosts('video'),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: _buildVideoGrid(recent),
        ),
      );
    });
  }


  Widget _buildSearchMode() {
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1))),
            child: TabBar(
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.4),
              indicatorColor: Colors.blueAccent,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
              tabs: const [
                Tab(text: 'Accounts'),
                Tab(text: 'Videos'),
                Tab(text: 'Images'),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (userController.isSearching.value) {
                return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
              }

              return TabBarView(
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildSearchAccountsTab(),
                  _buildSearchVideosTab(),
                  _buildSearchImagesTab(),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAccountsTab() {
    final users = userController.filteredUsers;
    if (users.isEmpty) return _buildEmptyState(Icons.people_outline, "No accounts found", "Try a different search term.");

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(15),
      itemCount: users.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white.withOpacity(0.05)),
      itemBuilder: (context, index) {
        final user = users[index];
        final position = user.playerDetails?.position ?? '';
        final location = user.state.isNotEmpty ? user.state : user.country;

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withOpacity(0.1),
            backgroundImage: user.profilePicture.isNotEmpty ? NetworkImage(user.profilePicture) : null,
            child: user.profilePicture.isEmpty ? const Icon(Icons.person, color: Colors.white54) : null,
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  user.role == 'club' ? (user.clubDetails?.clubName ?? user.name) : user.name,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              if (user.role == 'player' || user.role == 'club' || user.role == 'agent')
                const Padding(padding: EdgeInsets.only(left: 4), child: Icon(Icons.verified, color: Colors.blueAccent, size: 14)),
            ],
          ),
          subtitle: Text(
            "${user.role.capitalizeFirst}${position.isNotEmpty && user.role == 'player' ? ' • $position' : ''}${location.isNotEmpty ? '\n$location' : ''}",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
          ),
          onTap: () => Get.toNamed(AppRoutes.othersProfileScreen, arguments: {'targetId': user.id}),
        );
      },
    );
  }

  Widget _buildSearchVideosTab() {
    final videos = userController.searchVideos;
    if (videos.isEmpty) return _buildEmptyState(Icons.videocam_outlined, "No videos found", "Try a different search term.");
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: _buildVideoGrid(videos),
    );
  }

  Widget _buildSearchImagesTab() {
    final images = userController.searchImages;
    if (images.isEmpty) return _buildEmptyState(Icons.image_outlined, "No images found", "Try a different search term.");

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 2, mainAxisSpacing: 2, childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final post = images[index];
        return GestureDetector(
          onTap: () {
            Get.to(() => ProfileImageViewer(imageUrl: post.image?.url ??''));
          },
          child: Container(
            color: Colors.white.withOpacity(0.05),
            child: Image.network(
              post.image?.url ?? '',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image, color: Colors.white24),
            ),
          ),
        );
      },
    );
  }

  // ===========================================================================
  // COMMON UI WIDGETS
  // ===========================================================================

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search talents, clubs, highlights...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  prefixIcon: Icon(Iconsax.search_normal, color: Colors.white.withOpacity(0.5), size: 18),
                  suffixIcon: Obx(() => userController.searchQuery.value.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                    onPressed: () {
                      searchController.clear();
                      userController.onSearchChanged('');
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : const SizedBox.shrink()),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) => userController.onSearchChanged(value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: _showFilterModal,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent.withOpacity(0.2), Colors.blueAccent.withOpacity(0.05)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Iconsax.setting_4, color: Colors.blueAccent, size: 22),
                  if (_selectedPositions.isNotEmpty || _selectedCountry != null || _selectedRole.isNotEmpty)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 8, height: 8,
                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                      ),
                    )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            if (onTap != null) const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumProfileCard(UserModel user) {
    final bool isPlayer = user.role == 'player';
    final String position = user.playerDetails?.position ?? 'Player';
    final String location = user.state.isNotEmpty ? user.state : (user.country.isNotEmpty ? user.country : 'Unknown');

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.othersProfileScreen, arguments: {'targetId': user.id}),
      child: Container(
        width: 150,
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned(
                top: -20, right: -20,
                child: Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.2), shape: BoxShape.circle),
                  child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), child: Container()),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 35,
                        backgroundColor: const Color(0xFF1F2937),
                        backgroundImage: user.profilePicture.isNotEmpty ? NetworkImage(user.profilePicture) : null,
                        child: user.profilePicture.isEmpty ? const Icon(Icons.person, color: Colors.white54) : null,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            user.role == 'club' ? (user.clubDetails?.clubName ?? user.name): user.role == 'agent' ? user.agentDetails?.agencyName ?? user.name : user.name.capitalizeFirst ?? 'Unknown',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ),
                        if (user.role == 'player' || user.role == 'club' || user.role == 'agent') ...[
                          const SizedBox(width: 4),
                          const Icon(Icons.verified, color: Colors.blueAccent, size: 12),
                        ]
                      ],
                    ),
                    const SizedBox(height: 4),

                    Text(
                      isPlayer ? position.toUpperCase() : user.role.capitalizeFirst ?? '',
                      style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                    ),

                    const Spacer(),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: const Center(
                        child: Text("View Profile", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalVideoList(List<dynamic> videos) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: videos.length,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            child: InkWell(
              onTap: () {
                List<PostModel> searchPosts = videos.map((e) => e as PostModel).toList();
                Get.to(() => ProfileReelsPlayer(videos: searchPosts, initialIndex: index));
              },
              child: _buildVideoCard(videos[index]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid(List<dynamic> videos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75, // Taller cards
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            List<PostModel> searchPosts = videos.map((e) => e as PostModel).toList();
            Get.to(() => ProfileReelsPlayer(videos: searchPosts, initialIndex: index));
          },
          child: _buildVideoCard(videos[index]),
        );
      },
    );
  }

  Widget _buildVideoCard(dynamic videoData) {
    final PostModel post = videoData as PostModel;
    final video = post.video;

    String durationStr = '';
    if (video?.duration != null) {
      final int totalSeconds = video!.duration!.round();
      final int minutes = totalSeconds ~/ 60;
      final int seconds = totalSeconds % 60;
      durationStr = '$minutes:${seconds.toString().padLeft(2, '0')}';
    }

    final int likesCount = post.likes.length;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF1F2937),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            video?.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF030A1B), child: const Center(child: Icon(Icons.videocam_off_outlined, color: Colors.white24, size: 30))),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent, Colors.transparent, Colors.black.withOpacity(0.95)],
                stops: const [0.0, 0.25, 0.5, 1.0],
              ),
            ),
          ),

          Positioned(
            top: 10, left: 8, right: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (likesCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.favorite, color: Colors.redAccent, size: 10),
                        const SizedBox(width: 4),
                        Text(likesCount.toString(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                else const SizedBox(),

                if (durationStr.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.white.withOpacity(0.1))),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 12),
                        const SizedBox(width: 2),
                        Text(durationStr, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ),

          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle, border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5)),
                  child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: 12, left: 10, right: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video?.title?.isNotEmpty == true ? video!.title! : (post.text?.isNotEmpty == true ? post.text! : 'Highlight'),
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13, height: 1.2, letterSpacing: 0.2),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 9,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      backgroundImage: post.author?.profilePicture != null && post.author!.profilePicture.isNotEmpty ? NetworkImage(post.author!.profilePicture) : null,
                      child: post.author?.profilePicture == null || post.author!.profilePicture.isEmpty ? const Icon(Icons.person, size: 10, color: Colors.white54) : null,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        post.author?.name ?? 'Unknown User',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 11, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: Column(
          children: [
            Icon(icon, size: 60, color: Colors.white.withOpacity(0.1)),
            const SizedBox(height: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            Text(message, style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5))),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PREMIUM FILTER MODAL
  // ===========================================================================

  void _showFilterModal() {
    _selectedRole = userController.selectedRole.value;
    _selectedPositions = List.from(userController.selectedPositions);
    _selectedAgeRange = userController.selectedAgeRange.value;
    _selectedFoot = userController.selectedFoot.value;
    _selectedAvailability = userController.selectedAvailability.value;
    _selectedExperience = userController.selectedExperience.value;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: Container(width: 40, height: 5, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)))),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Advanced Filters", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            _selectedRole = ''; _selectedPositions.clear(); _selectedAgeRange = '';
                            _selectedFoot = ''; _selectedAvailability = ''; _selectedExperience = '';
                            _selectedCountry = null; _selectedState = null; _selectedLga = null;
                          });
                        },
                        child: const Text("Clear All", style: TextStyle(color: Colors.redAccent)),
                      )
                    ],
                  ),
                  const SizedBox(height: 15),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterLabel("Account Type"),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildChip('Player', Icons.sports_soccer, _selectedRole == 'player', () => setModalState(() => _selectedRole = 'player')),
                                const SizedBox(width: 10),
                                _buildChip('Club', Icons.shield, _selectedRole == 'club', () => setModalState(() => _selectedRole = 'club')),
                                const SizedBox(width: 10),
                                _buildChip('Agent', Icons.business_center, _selectedRole == 'agent', () => setModalState(() => _selectedRole = 'agent')),
                              ],
                            ),
                          ),
                          const SizedBox(height: 25),

                          if (_selectedRole == 'player' || _selectedRole.isEmpty) ...[
                            _buildFilterLabel("Player Details"),
                            _buildPremiumFilterTile(
                              title: "Positions",
                              value: _selectedPositions.isEmpty ? 'Any' : _selectedPositions.join(', '),
                              icon: Icons.run_circle_outlined,
                              onTap: () => Get.bottomSheet(
                                GroupedPositionSelector(
                                  initialSelections: _selectedPositions,
                                  onSave: (list) => setModalState(() => _selectedPositions = list),
                                ),
                                isScrollControlled: true,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _buildPremiumFilterTile(
                              title: "Age Range",
                              value: _selectedAgeRange.isEmpty ? 'Any' : _selectedAgeRange,
                              icon: Icons.cake_outlined,
                              onTap: () => _showSimplePicker("Age Range", ['U18', '18-20', '21-29', '30-34', '35+'], (v) => setModalState(() => _selectedAgeRange = v)),
                            ),
                            const SizedBox(height: 10),
                            _buildPremiumFilterTile(
                              title: "Preferred Foot",
                              value: _selectedFoot.isEmpty ? 'Any' : _selectedFoot.capitalizeFirst!,
                              icon: Icons.sports_soccer,
                              onTap: () => _showSimplePicker("Preferred Foot", ['Left', 'Right', 'Both'], (v) => setModalState(() => _selectedFoot = v)),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: const Icon(Icons.transfer_within_a_station, color: Colors.blueAccent),
                                  hintText: "Availability (e.g. Free Agent, Chelsea)",
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                                ),
                                onChanged: (v) => _selectedAvailability = v,
                                controller: TextEditingController(text: _selectedAvailability)..selection = TextSelection.collapsed(offset: _selectedAvailability.length),
                              ),
                            ),
                            const SizedBox(height: 25),
                          ],

                          if (_selectedRole == 'agent') ...[
                            _buildFilterLabel("Agent Details"),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.08))),
                              child: TextField(
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  icon: const Icon(Icons.work_history, color: Colors.blueAccent),
                                  hintText: "Experience (e.g. FIFA Pro, 5 years)",
                                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 14),
                                ),
                                onChanged: (v) => _selectedExperience = v,
                              ),
                            ),
                            const SizedBox(height: 25),
                          ],

                          _buildFilterLabel("Location"),
                          CountryState(
                            selectedCountry: _selectedCountry,
                            selectedState: _selectedState,
                            selectedLga: _selectedLga,
                            onCountryChanged: (c) => setModalState(() { _selectedCountry = c; _selectedState = null; _selectedLga = null; }),
                            onStateChanged: (s) => setModalState(() { _selectedState = s; _selectedLga = null; }),
                            onLgaChanged: (l) => setModalState(() { _selectedLga = l; }),
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    width: double.infinity, height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        String finalRegion = _selectedLga ?? _selectedState ?? _selectedCountry ?? '';
                        userController.selectedRole.value = _selectedRole;
                        userController.selectedPositions.assignAll(_selectedPositions);
                        userController.selectedAgeRange.value = _selectedAgeRange;
                        userController.selectedFoot.value = _selectedFoot;
                        userController.selectedAvailability.value = _selectedAvailability;
                        userController.selectedExperience.value = _selectedExperience;
                        userController.selectedRegion.value = finalRegion;
                        userController.applyFilters();
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                      child: const Text("Apply Filters", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterLabel(String text) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(text.toUpperCase(), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)));

  Widget _buildChip(String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumFilterTile({required String title, required String value, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
              child: Icon(icon, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(value.isEmpty ? 'Any' : value, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }

  void _showSimplePicker(String title, List<String> options, Function(String) onSelect) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2937),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)))),
              Padding(padding: const EdgeInsets.all(20), child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white))),
              ...options.map((opt) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  title: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 16)),
                  onTap: () {
                    onSelect(opt);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}

class GroupedPositionSelector extends StatefulWidget {
  final List<String> initialSelections;
  final Function(List<String>) onSave;

  const GroupedPositionSelector({super.key, required this.initialSelections, required this.onSave});

  @override
  State<GroupedPositionSelector> createState() => _GroupedPositionSelectorState();
}

class _GroupedPositionSelectorState extends State<GroupedPositionSelector> {
  late List<String> _tempSelected;

  final Map<String, List<String>> _groupedPositions = {
    "Attackers": ["ST — Striker", "CF — Center Forward", "SS — Second Striker", "LW — Left Winger", "RW — Right Winger", "LF — Left Forward", "RF — Right Forward", "WF — Wide Forward", "IF — Inside Forward"],
    "Midfielders": ["CAM — Attacking Midfielder", "CM — Central Midfielder", "CDM — Defensive Midfielder", "LM — Left Midfielder", "RM — Right Midfielder", "MF — Midfielder"],
    "Defenders": ["CB — Center Back", "LB — Left Back", "RB — Right Back", "LWB — Left Wing Back", "RWB — Right Wing Back", "SW — Sweeper", "WB — Wing Back", "DF — Defender"],
    "Goalkeepers": ["GK — Goalkeeper"],
  };

  @override
  void initState() {
    super.initState();
    _tempSelected = List.from(widget.initialSelections);
  }

  void _togglePosition(String abbreviation) {
    setState(() {
      if (_tempSelected.contains(abbreviation)) {
        _tempSelected.remove(abbreviation);
      } else {
        _tempSelected.add(abbreviation);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(color: Color(0xFF1F2937), borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10))),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Select Positions", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () { widget.onSave(_tempSelected); Get.back(); }, child: const Text("Done", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 16)))
              ],
            ),
          ),
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              children: _groupedPositions.entries.map((category) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 5),
                      child: Text(category.key.toUpperCase(), style: TextStyle(color: Colors.blueAccent.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    ),
                    ...category.value.map((pos) {
                      final abbreviation = pos.split('—')[0].trim();
                      final isSelected = _tempSelected.contains(abbreviation);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                        title: Text(pos, style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.blueAccent) : const Icon(Icons.circle_outlined, color: Colors.white24),
                        onTap: () => _togglePosition(abbreviation),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class SeeAllUsersScreen extends StatelessWidget {
  final String title;
  final List<UserModel> users;

  const SeeAllUsersScreen({super.key, required this.title, required this.users});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B),
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        title: title,
        leadingIcon: const BackButton(color: Colors.white),
      ),
      body: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(15),
        itemCount: users.length,
        separatorBuilder: (context, index) => Divider(color: Colors.white.withOpacity(0.05)),
        itemBuilder: (context, index) {
          final user = users[index];
          final position = user.playerDetails?.position ?? '';
          final location = user.state.isNotEmpty ? user.state : user.country;

          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white.withOpacity(0.1),
              backgroundImage: user.profilePicture.isNotEmpty ? NetworkImage(user.profilePicture) : null,
              child: user.profilePicture.isEmpty ? const Icon(Icons.person, color: Colors.white54) : null,
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    user.role == 'club' ? (user.clubDetails?.clubName ?? user.name) : user.name,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                if (user.role == 'player' || user.role == 'club' || user.role == 'agent')
                  const Padding(
                    padding: EdgeInsets.only(left: 4),
                    child: Icon(Icons.verified, color: Colors.blueAccent, size: 14),
                  ),
              ],
            ),
            subtitle: Text(
              "${user.role.capitalizeFirst}${position.isNotEmpty && user.role == 'player' ? ' • $position' : ''}${location.isNotEmpty ? '\n$location' : ''}",
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text("View", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            ),
            onTap: () => Get.toNamed(AppRoutes.othersProfileScreen, arguments: {'targetId': user.id}),
          );
        },
      ),
    );
  }
}

