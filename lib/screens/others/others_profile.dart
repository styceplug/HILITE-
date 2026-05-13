import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/screens/home/pages/profile_screen.dart';
import 'package:hilite/screens/others/relationship_screen.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../data/repo/chat_repo.dart';
import '../../models/message_model.dart';
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../routes/routes.dart';
import 'package:intl/intl.dart';

import '../../utils/others.dart';
import '../../widgets/reels_video_item.dart';


class OthersProfileScreen extends StatefulWidget {
  const OthersProfileScreen({super.key});

  @override
  State<OthersProfileScreen> createState() => _OthersProfileState();
}

class _OthersProfileState extends State<OthersProfileScreen> {
  final UserController userController = Get.find<UserController>();
  String? targetId;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>?;
    targetId = args?['targetId'] as String?;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (targetId != null) {
        // --- THIS IS THE ONLY PLACE WE SHOULD FETCH ---
        userController.prepareExternalProfile(targetId!);
        userController.getOthersProfile(targetId!, resetBeforeFetch: true);
        userController.getAllExternalUserPosts(targetId!);
      } else {
        Get.snackbar('Error', 'User not found', backgroundColor: Colors.red, colorText: Colors.white);
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
      body: GetBuilder<UserController>(
        builder: (controller) {
          if (targetId == null) return const SizedBox.shrink();

          final realUser = controller.othersProfile.value;

          // Determine if we are loading
          final bool isLoadingProfile = controller.isOthersProfileLoading.value || realUser == null || realUser.id != targetId;

          // Smart Skeletonizer Logic using strictly typed Mock User
          final user = isLoadingProfile ? _getMockUser() : realUser;
          final isFollowing = user.isFollowed;
          final isFollowBusy = controller.isFollowActionInProgress(user.id);


          final bool isOwnProfile = controller.user.value?.id == user.id;

          var club = user.clubDetails;

          // Determine Tabs by Role
          List<String> profileTabs;
          switch (user.role.toLowerCase()) {
            case 'club':
              profileTabs = ['Squad', 'Highlights', 'Info'];
              break;
            case 'agent':
              profileTabs = ['Scouted', 'Highlights', 'Info'];
              break;
            case 'player':
            default:
              profileTabs = ['Highlights', 'Info'];
              break;
          }
          if (_selectedTabIndex >= profileTabs.length) _selectedTabIndex = 0;

          return Skeletonizer(
            enabled: isLoadingProfile,
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // --- 1. App Bar Area ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                              onPressed: () => Get.back(),
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
                            child: IconButton(
                              icon: const Icon(Icons.more_horiz, color: Colors.white),
                              onPressed: isLoadingProfile ? null : () => _showProfileDetails(context, user),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // --- 2. Avatar ---
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2), width: 3),
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: user.profilePicture.isNotEmpty ? NetworkImage(user.profilePicture) : null,
                        child: user.profilePicture.isEmpty ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                      ),
                    ),
                    const SizedBox(height: 15),

                    // --- 3. Name & Subtitle ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          user.role == 'club' ? (club?.clubName ?? user.name) : user.name.capitalizeFirst ?? 'Unknown',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(user),
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6)),
                    ),
                    const SizedBox(height: 10),

                    // --- 4. Pill Badge ---
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.verified, color: Colors.blueAccent, size: 14),
                          const SizedBox(width: 5),
                          Text(
                            _buildBadgeLabel(user),
                            style: const TextStyle(fontSize: 12, color: Colors.blueAccent, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- 5. Stats Row (Followers | Following) ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStatBlock(_formatNumber(user.followers), 'Followers', 'followers', user, isLoadingProfile),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          height: 20,
                          width: 1,
                          color: Colors.white.withOpacity(0.2),
                        ),
                        _buildStatBlock(_formatNumber(user.following), 'Following', 'following', user, isLoadingProfile),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // --- 6. Action Buttons ---
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              // --- FIX: Disabled if Own Profile ---
                              onPressed: isLoadingProfile || isFollowBusy || isOwnProfile ? null : () {
                                if (!isFollowing) {
                                  userController.followUser(user.id);
                                } else {
                                  userController.unfollowUser(user.id);
                                }
                              },
                              icon: isFollowBusy
                                  ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Icon(Icons.person_add_alt_1, color: isFollowing ? Colors.white : Colors.white, size: 18),
                              label: Text(isFollowing ? 'Unfollow' : 'Follow', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isFollowing ? Colors.white.withOpacity(0.05) : const Color(0xFF1E293B),
                                disabledBackgroundColor: Colors.white.withOpacity(0.05),
                                disabledForegroundColor: Colors.white.withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: ElevatedButton.icon(
                              // --- FIX: Disabled if Own Profile ---
                              onPressed: isLoadingProfile || isOwnProfile ? null : () async {
                                try {
                                  final chatRepo = Get.find<ChatRepo>();
                                  final response = await chatRepo.getOrCreateChat(user.id);

                                  if (response.statusCode == 200 && response.body['code'] == '00') {
                                    final chat = Chat.fromJson(Map<String, dynamic>.from(response.body['data']));
                                    Get.toNamed(
                                      AppRoutes.messagingScreen,
                                      arguments: {
                                        'chat': chat,
                                        'peerName': user.name,
                                        'peerUsername': user.username,
                                        'peerProfilePicture': user.profilePicture,
                                      },
                                    );
                                  } else {
                                    Get.snackbar('Error', response.body?['message'] ?? 'Unable to open chat', backgroundColor: Colors.red, colorText: Colors.white);
                                  }
                                } catch (e) {
                                  Get.snackbar('Error', 'Unable to open chat: $e', backgroundColor: Colors.red, colorText: Colors.white);
                                }
                              },
                              icon: const Icon(Icons.message_rounded, color: Colors.white, size: 18),
                              label: const Text('Message', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                disabledBackgroundColor: Colors.white.withOpacity(0.05),
                                disabledForegroundColor: Colors.white.withOpacity(0.3),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                elevation: 0,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // --- 7. TABS ---
                    _buildCustomTabBar(profileTabs),
                    const SizedBox(height: 15),

                    // --- 8. TAB CONTENT ---
                    _buildSelectedTabContent(controller, profileTabs[_selectedTabIndex], user, isLoadingProfile),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // --- UI HELPERS ---

  String _formatNumber(int number) {
    if (number >= 1000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    if (number >= 1000) return '${(number / 1000).toStringAsFixed(1)}K';
    return number.toString();
  }

  String _buildSubtitle(UserModel user) {
    String age = '';
    if (user.role == 'player' && user.playerDetails?.dob != null) {
      final calculatedAge = _calculateAge(user.playerDetails!.dob);
      if (calculatedAge != null) age = '$calculatedAge • ';
    }

    String country = user.country.isNotEmpty ? user.country : 'Unknown Location';

    if (user.role == 'player') {
      return '${user.playerDetails?.position.toUpperCase() ?? 'Player'} • $age$country';
    } else if (user.role == 'club') {
      return '${user.clubDetails?.clubType.capitalizeFirst ?? 'Professional Club'} • $country • ${user.clubDetails?.yearFounded ?? ''}';
    } else if (user.role == 'agent') {
      return 'Head Scout • ${user.agentDetails?.agencyName ?? 'Independent'}';
    }
    return 'Fan • $country';
  }

  String _buildBadgeLabel(UserModel user) {
    if (user.role == 'player') return 'Verified Player';
    if (user.role == 'agent') return 'Verified Scout';
    if (user.role == 'club') return 'Verified Club';
    return 'Verified Account';
  }

  Widget _buildStatBlock(String value, String label, String type, UserModel user, bool isLoading) {
    return InkWell(
      onTap: isLoading ? null : () {
        Get.to(() => RelationshipScreen(
          title: label,
          type: type,
          targetId: user.id,
        ));
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.6))),
        ],
      ),
    );
  }

  Widget _buildPlayerStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 30, width: 1, color: Colors.white.withOpacity(0.1));
  }

  // --- TABS LOGIC ---

  Widget _buildCustomTabBar(List<String> tabs) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.1), width: 1))),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      tabs[index].toUpperCase(),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 2,
                    width: isSelected ? 40 : 0,
                    decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(2)),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSelectedTabContent(UserController controller, String currentTab, UserModel user, bool isLoading) {
    if (currentTab == 'Highlights') {
      final bool isLoadingPosts = controller.isExternalPostsLoading && controller.externalPosts.isEmpty;
      if (isLoadingPosts || isLoading) {
        return _buildCombinedContentGrid(controller, user, dummyPosts: _getMockPosts());
      }
      if (controller.externalPosts.isEmpty) {
        return Padding(
          padding: const EdgeInsets.all(40),
          child: Text("No highlights yet.", style: TextStyle(color: Colors.white.withOpacity(0.5))),
        );
      }
      return Column(
        children: [
          _buildCombinedContentGrid(controller, user),
          const SizedBox(height: 15),
          TextButton(
            onPressed: () {},
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("View all highlights", style: TextStyle(color: Colors.blueAccent)),
                Icon(Icons.chevron_right, color: Colors.blueAccent, size: 18),
              ],
            ),
          )
        ],
      );
    } else if (currentTab == 'Squad' || currentTab == 'Scouted') {
      return _buildSquadList();
    } else if (currentTab == 'Info') {
      // ✅ ALL INFO / BIO NOW RENDERED HERE
      return _buildInfoTab(user);
    }
    return const SizedBox.shrink();
  }

  // --- INFO TAB ---
  Widget _buildInfoTab(UserModel user) {
    var player = user.playerDetails;
    var club = user.clubDetails;
    var agent = user.agentDetails;

    return Container(
      width: Dimensions.screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BIO / ABOUT
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const Text("About", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Text(
              user.bio!,
              style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.7), height: 1.5),
            ),
            const SizedBox(height: 25),
          ],

          // PLAYER STATS
          if (user.role == 'player') ...[
            const Text("Player Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerStat('Position', player?.position.toUpperCase() ?? '-'),
                _buildVerticalDivider(),
                _buildPlayerStat('Height', '${player?.height ?? '-'} cm'),
                _buildVerticalDivider(),
                _buildPlayerStat('Weight', '${player?.weight ?? '-'} kg'),
                _buildVerticalDivider(),
                _buildPlayerStat('Foot', player?.preferredFoot.capitalizeFirst ?? '-'),
              ],
            ),
          ],

          // CLUB STATS
          if (user.role == 'club') ...[
            const Text("Club Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildPlayerStat('Type', club?.clubType.capitalizeFirst ?? '-'),
                _buildVerticalDivider(),
                _buildPlayerStat('Manager', club?.manager ?? '-'),
                _buildVerticalDivider(),
                _buildPlayerStat('Founded', club?.yearFounded ?? '-'),
              ],
            ),
          ],

          // AGENT STATS
          if (user.role == 'agent') ...[
            const Text("Agent Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPlayerStat('Agency', agent?.agencyName ?? '-'),
                _buildVerticalDivider(),
                _buildPlayerStat('Experience', agent?.experience ?? '-'),
              ],
            ),
          ],
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- GRID RENDERER ---
  Widget _buildCombinedContentGrid(UserController controller, UserModel user, {List<PersonalPostModel>? dummyPosts}) {
    final posts = dummyPosts ?? controller.externalPosts;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
        childAspectRatio: 0.65,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        final isVideo = post.type == 'video';
        final imageUrl = isVideo ? (post.thumbnail ?? post.mediaUrl ?? '') : (post.mediaUrl ?? '');
        final dateFormatted = DateFormat('MMM d, yyyy').format(post.createdAt);

        return GestureDetector(
          onTap: dummyPosts != null ? null : () {
            if (post.type == 'video') {
              final videoOnly = posts.where((p) => p.type == 'video').toList();
              final converted = videoOnly.map((p) => personalToPostModel(p, authorProfile: controller.othersProfile.value)).toList();
              final tappedVideoIndex = videoOnly.indexWhere((p) => p.id == post.id);

              Get.to(() => ProfileReelsPlayer(
                videos: converted,
                initialIndex: tappedVideoIndex == -1 ? 0 : tappedVideoIndex,
                authorProfile: controller.othersProfile.value,
              ));
            } else {
              Get.to(() => ProfileImageViewer(imageUrl: post.mediaUrl ?? ''));
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.white.withOpacity(0.05),
                        child: imageUrl.isNotEmpty
                            ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.broken_image, color: Colors.white.withOpacity(0.2)))
                            : Icon(Icons.image, color: Colors.white.withOpacity(0.2)),
                      ),
                      if (isVideo) ...[
                        Container(color: Colors.black.withOpacity(0.2)),
                        Center(child: Icon(Icons.play_arrow_rounded, color: Colors.white.withOpacity(0.9), size: 36)),
                        if (post.duration != null)
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                "${post.duration!.round()}s",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          )
                      ]
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(user.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              Text(dateFormatted, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 11)),
            ],
          ),
        );
      },
    );
  }

  // --- SQUAD LIST ---
  Widget _buildSquadList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_activity, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 10),
                const Expanded(child: Text("Open to Trials & Recruiting Players", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))),
                Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.5)),
              ],
            ),
          ),
          const SizedBox(height: 25),
          const Text("Squad", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          ...List.generate(4, (index) => _buildSquadTile("Adebiyi Adebayo", "CAM • 22 • Nigeria")),
        ],
      ),
    );
  }

  Widget _buildSquadTile(String name, String details) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          const CircleAvatar(radius: 20, backgroundColor: Colors.grey, child: Icon(Icons.person, color: Colors.white)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                Text(details, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
          const Text("Starter", style: TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- HELPERS ---
  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) age--;
    return age;
  }

  String _footballAgeRangeLabel(DateTime? dob) {
    final age = _calculateAge(dob);
    if (age == null) return 'Not listed';
    if (age < 18) return 'U18';
    if (age < 21) return 'U21';
    if (age < 30) return 'U30';
    if (age < 35) return 'U34';
    return '35+';
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

  // --- FULL BOTTOM SHEET ---
  void _showProfileDetails(BuildContext context, UserModel user) {
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1F2937),
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person_pin_circle_outlined, color: Colors.blueAccent, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'About this Account',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 25),

            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('General Information'),
                    _buildDetailRow(Icons.person_outline, 'Full Name', user.name),
                    _buildDetailRow(Icons.alternate_email, 'Username', '@${user.username}'),
                    if (user.country.isNotEmpty) _buildDetailRow(Icons.flag_outlined, 'Country', user.country),
                    if (user.state.isNotEmpty) _buildDetailRow(Icons.location_city, 'State/Region', user.state),
                    _buildDetailRow(Icons.calendar_today, 'Joined', _formatDate(user.createdAt.toString())),

                    const SizedBox(height: 15),

                    if (user.role == 'player' && user.playerDetails != null) ...[
                      _buildSectionTitle('Player Details'),
                      _buildDetailRow(Icons.sports_soccer, 'Position', user.playerDetails?.position ?? '-'),
                      _buildDetailRow(Icons.shield_outlined, 'Current Club', user.playerDetails?.currentClub ?? '-'),
                      _buildDetailRow(Icons.straighten, 'Height', '${user.playerDetails?.height ?? '-'} cm'),
                      _buildDetailRow(Icons.fitness_center, 'Weight', '${user.playerDetails?.weight ?? '-'} kg'),
                      _buildDetailRow(Icons.do_not_step, 'Preferred Foot', user.playerDetails?.preferredFoot.capitalizeFirst ?? '-'),
                      _buildDetailRow(Icons.cake, 'Age Range', _footballAgeRangeLabel(user.playerDetails?.dob)),
                    ],

                    if (user.role == 'club' && user.clubDetails != null) ...[
                      _buildSectionTitle('Club Details'),
                      _buildDetailRow(Icons.shield, 'Club Name', user.clubDetails?.clubName ?? user.name),
                      _buildDetailRow(Icons.category, 'Type', user.clubDetails?.clubType.capitalizeFirst ?? '-'),
                      _buildDetailRow(Icons.person, 'Manager', user.clubDetails?.manager ?? '-'),
                      _buildDetailRow(Icons.history, 'Founded', user.clubDetails?.yearFounded ?? '-'),
                    ],

                    if (user.role == 'agent' && user.agentDetails != null) ...[
                      _buildSectionTitle('Agent Profile'),
                      _buildDetailRow(Icons.business_center, 'Agency', user.agentDetails?.agencyName ?? '-'),
                      _buildDetailRow(Icons.verified_user, 'Registration ID', user.agentDetails?.registrationId ?? 'Not Listed'),
                      _buildDetailRow(Icons.work_history, 'Experience', user.agentDetails?.experience ?? '-'),
                    ],
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
      padding: const EdgeInsets.only(bottom: 15, top: 10),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white.withOpacity(0.5), letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: Colors.blueAccent),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.5), fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- STRICTLY TYPED MOCK DATA ---
  UserModel _getMockUser() {
    return UserModel(
        id: 'mock',
        name: 'Loading Name',
        username: 'loading',
        email: '',
        role: 'player',
        number: '',
        country: 'Country',
        state: 'State',
        profilePicture: '',
        tokenBalance: '0',
        followers: 12500,
        following: 800,
        blocked: 0,
        bookmarks: 0,
        posts: 0,
        bio: 'I am a dedicated football scout with a strong eye for identifying raw talent, tactical intelligence, and long-term player potential...',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        playerDetails: PlayerDetails(
          dob: DateTime.now().subtract(const Duration(days: 365 * 22)),
          position: 'CAM',
          currentClub: '',
          preferredFoot: 'Right',
          height: 180,
          weight: 75,
        )
    );
  }

  List<PersonalPostModel> _getMockPosts() {
    return List.generate(3, (index) => PersonalPostModel(
      id: 'mock_$index',
      type: 'video',
      createdAt: DateTime.now(),
      mediaUrl: '',
      thumbnail: '',
    ));
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    // Get screen size to make the circle responsive
    final double size = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      // TikTok uses a solid black/dark background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.white),
      ),
      // Extend body behind app bar for full immersion
      extendBodyBehindAppBar: true,
      body: Center(
        child: GestureDetector(
          onTap: () => Get.back(), // Tap anywhere to close
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 0.5,
            maxScale: 4,
            child: Hero(
              tag: imageUrl,
              // ClipOval forces the image into a circle
              child: ClipOval(
                child: Image.network(
                  imageUrl,
                  // Use width & height to force a square, which ClipOval turns into a circle
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  // Ensures the image fills the circle
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return SizedBox(
                      width: size,
                      height: size,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  },
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        width: size,
                        height: size,
                        color: Colors.grey[900],
                        child: const Icon(
                          Icons.error,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
