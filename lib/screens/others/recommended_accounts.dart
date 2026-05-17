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


class RecommendedAccountsScreen extends StatefulWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  State<RecommendedAccountsScreen> createState() => _RecommendedAccountsScreenState();
}

class _RecommendedAccountsScreenState extends State<RecommendedAccountsScreen> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController searchController = TextEditingController();

  // --- FILTER STATES ---
  String _selectedPosition = '';
  String _selectedLocation = '';
  String _selectedAvailability = '';
  String _selectedFoot = '';
  String _selectedExperience = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userController.recommendedUsers.isEmpty) {
        userController.getRecommendedUsers();
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
      length: 3, // For You, By Position, Recently Added
      child: Scaffold(
        backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
        appBar: CustomAppbar(
          backgroundColor: const Color(0xFF030A1B),
          title: 'Discover',
          leadingIcon: const BackButton(color: Colors.white),
        ),
        body: Column(
          children: [
            // --- 1. Search Bar & Filter Icon Row ---
            _buildSearchAndFilterRow(),

            // --- 2. Tab Bar ---
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
              ),
              child: TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white.withOpacity(0.5),
                indicatorColor: Colors.blueAccent,
                indicatorWeight: 3,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
                tabs: const [
                  Tab(text: 'For You'),
                  Tab(text: 'By Position'),
                  Tab(text: 'Recently Added'),
                ],
              ),
            ),

            // --- 3. Tab Views ---
            Expanded(
              child: TabBarView(
                children: [
                  _buildForYouTab(),
                  _buildPlaceholderTab("Videos sorted by position will appear here"),
                  _buildPlaceholderTab("Freshly uploaded videos will appear here"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // UI COMPONENTS
  // ===========================================================================

  Widget _buildSearchAndFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 10, 15, 15),
      child: Row(
        children: [
          // Search Field
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: searchController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search talents, highlights...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14),
                  prefixIcon: Icon(Iconsax.search_normal, color: Colors.white.withOpacity(0.5), size: 20),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onChanged: (value) => userController.onSearchChanged(value),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Filter Button
          InkWell(
            onTap: _showFilterModal,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
              ),
              child: const Icon(Iconsax.setting_4, color: Colors.blueAccent, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  // --- FOR YOU TAB (HORIZONTAL CAROUSELS) ---
  Widget _buildForYouTab() {
    return Obx(() {
      if (userController.isSearching.value) {
        return const Center(child: CircularProgressIndicator(color: Colors.blueAccent));
      }

      // Mock Lists (Replace these with your actual controller lists: forYouVideos, trendingVideos, featuredVideos)
      final List<dynamic> forYouVideos = userController.searchVideos.isNotEmpty ? userController.searchVideos : [];
      final List<dynamic> trendingVideos = userController.searchVideos.isNotEmpty ? userController.searchVideos.reversed.toList() : [];
      final List<dynamic> featuredVideos = userController.searchVideos.isNotEmpty ? userController.searchVideos : [];

      if (forYouVideos.isEmpty) {
        return _buildEmptyState(Icons.video_library, "No videos found", "Start following users to see videos here.");
      }

      return RefreshIndicator(
        color: Colors.blueAccent,
        backgroundColor: const Color(0xFF1F2937),
        onRefresh: () async {
          // Add your refresh logic here
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHorizontalVideoSection("For You", forYouVideos),
              const SizedBox(height: 30),
              _buildHorizontalVideoSection("Trending", trendingVideos),
              const SizedBox(height: 30),
              _buildHorizontalVideoSection("Featured This Month", featuredVideos),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHorizontalVideoSection(String title, List<dynamic> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.chevron_right, color: Colors.white54),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240, // Fixed height for the horizontal scroll
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: videos.length,
            itemBuilder: (context, index) {
              return Container(
                width: 150, // Fixed width for each video card
                margin: const EdgeInsets.symmetric(horizontal: 5),
                child: InkWell(
                  onTap: () {
                    List<PostModel> searchPosts = videos.map((e) => e as PostModel).toList();
                    Get.to(() => ProfileReelsPlayer(
                      videos: searchPosts,
                      initialIndex: index,
                    ));
                  },
                  child: _buildVideoCard(videos[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // --- REUSABLE VIDEO CARD (Miniaturized for Horizontal List) ---
  Widget _buildVideoCard(dynamic videoData) {
    final PostModel post = videoData as PostModel;
    final video = post.video;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white.withOpacity(0.05),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail
          Image.network(
            video?.thumbnailUrl ?? '',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.black26,
                child: const Icon(Icons.video_library, size: 30, color: Colors.white24),
              );
            },
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                stops: const [0.5, 1.0],
              ),
            ),
          ),

          // Play Icon
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
            ),
          ),

          // Title, User and Duration
          Positioned(
            bottom: 8,
            left: 8,
            right: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video?.title ?? post.text ?? 'Highlight',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, height: 1.2),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "@${post.author?.username ?? 'user'}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10),
                      ),
                    ),
                    if (video?.duration != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          "${video!.duration?.toStringAsFixed(0)}s",
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
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

  // ===========================================================================
  // FILTER MODAL
  // ===========================================================================

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: const BoxDecoration(
                color: Color(0xFF1F2937),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const Text("Filters", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 25),

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFilterDropdown("Position", _selectedPosition, ['Forward', 'Midfielder', 'Defender', 'Goalkeeper'], (val) => setModalState(() => _selectedPosition = val!)),
                          const SizedBox(height: 20),
                          _buildFilterDropdown("Location", _selectedLocation, ['Lagos', 'Abuja', 'Kano', 'Rivers'], (val) => setModalState(() => _selectedLocation = val!)),
                          const SizedBox(height: 20),
                          _buildFilterDropdown("Availability", _selectedAvailability, ['Free Agent', 'Under Contract', 'Loan'], (val) => setModalState(() => _selectedAvailability = val!)),
                          const SizedBox(height: 20),
                          _buildFilterDropdown("Preferred Foot", _selectedFoot, ['Right', 'Left', 'Both'], (val) => setModalState(() => _selectedFoot = val!)),
                          const SizedBox(height: 20),
                          _buildFilterDropdown("Experience", _selectedExperience, ['Amateur', 'Academy', 'Semi-Pro', 'Professional'], (val) => setModalState(() => _selectedExperience = val!)),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Buttons (Apply & Reset)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedPosition = '';
                              _selectedLocation = '';
                              _selectedAvailability = '';
                              _selectedFoot = '';
                              _selectedExperience = '';
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Reset", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // TODO: Apply filter logic here
                            Get.back();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blueAccent,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown(String label, String currentValue, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              dropdownColor: const Color(0xFF1F2937),
              value: currentValue.isEmpty ? null : currentValue,
              hint: Text("Select $label", style: TextStyle(color: Colors.white.withOpacity(0.3))),
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white.withOpacity(0.5)),
              style: const TextStyle(color: Colors.white, fontSize: 15),
              items: options.map((String value) {
                return DropdownMenuItem<String>(value: value, child: Text(value));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // --- HELPERS ---

  Widget _buildPlaceholderTab(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.video_library_outlined, size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 15),
          Text(text, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 20),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 10),
          Text(message, style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.5))),
        ],
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
