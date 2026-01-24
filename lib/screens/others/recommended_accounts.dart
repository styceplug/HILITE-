import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/custom_appbar.dart';

import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';


import '../../models/user_model.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class RecommendedAccountsScreen extends StatefulWidget {
  const RecommendedAccountsScreen({super.key});

  @override
  State<RecommendedAccountsScreen> createState() =>
      _RecommendedAccountsScreenState();
}

class _RecommendedAccountsScreenState extends State<RecommendedAccountsScreen> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(userController.recommendedUsers.isEmpty){
        userController.getRecommendedUsers();
      } else {
        if(userController.filteredUsers.isEmpty){
          userController.filteredUsers.assignAll(userController.recommendedUsers);
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
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: CustomAppbar(
        title: 'Discover Accounts',
        leadingIcon: const BackButton(),
        actionIcon: IconButton(
          icon: Icon(Icons.info_outline, size: Dimensions.iconSize24),
          onPressed: () {
            _showInfoDialog(context);
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => userController.getRecommendedUsers(),
        color: AppColors.primary,
        child: Container(
          height: Dimensions.screenHeight,
          width: Dimensions.screenWidth,
          child: Column(
            children: [
              // Search & Filters Section
              Container(
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
                    // Search Bar
                    CustomTextField(
                      controller: searchController,
                      hintText: 'Search by name, club, username...',
                      prefixIcon: Icons.search,
                      suffixIcon: Obx(() {
                        return userController.searchQuery.value.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            searchController.clear();
                            userController.searchQuery.value = '';
                            userController.applyFilters();
                          },
                        )
                            : const SizedBox.shrink();
                      }),
                      onChanged: (value) {
                        userController.onSearchChanged(value);
                      },
                    ),

                    SizedBox(height: Dimensions.height15),

                    // Filter Chips
                    _buildFilterChips(),
                  ],
                ),
              ),

              // Results Section
              Obx(() {
                final hasFilters = userController.searchQuery.value.isNotEmpty ||
                    userController.selectedRole.value.isNotEmpty ||
                    userController.selectedPosition.value.isNotEmpty;

                return hasFilters
                    ? Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${userController.filteredUsers.length} results found',
                        style: TextStyle(
                          fontSize: Dimensions.font14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          searchController.clear();
                          userController.clearAllFilters();
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Clear All'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.width10,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                    : const SizedBox.shrink();
              }),

              // User List
              Expanded(
                child: Obx(() {
                  if (userController.recommendedUsers.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.people_outline,
                      title: 'No Recommendations Yet',
                      message: 'Check back later for account suggestions',
                    );
                  }

                  if (userController.filteredUsers.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.search_off,
                      title: 'No Results Found',
                      message: 'Try adjusting your filters',
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height15,
                    ),
                    itemCount: userController.filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = userController.filteredUsers[index];
                      return _buildAccountCard(user);
                    },
                  );
                }),
              ),
            ],
          ),
        ),
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
                  return Transform.scale(
                    scale: value,
                    child: child,
                  );
                },
                child: _buildFilterChip(
                  label: userController.selectedPosition.value.isEmpty
                      ? 'Position'
                      : userController.selectedPosition.value,
                  icon: Icons.location_on,
                  isSelected: userController.selectedPosition.value.isNotEmpty,
                  onTap: () {
                    _showPositionBottomSheet(context);
                  },
                ),
              ),
            ],

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
    final isFollowed = user.isFollowed ?? false;
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
          onTap: () => Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': user.id},
          ),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(Dimensions.width15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar section (unchanged)
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(
                        user.profilePicture ?? 'https://placehold.net/avatar-2.png',
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

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + Badge (unchanged)
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.role == 'club'
                                  ? (user.clubDetails?.clubName ?? 'Unknown')
                                  : (user.name.capitalizeFirst ?? 'Unknown'),
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
                          _buildVerifiedBadge(user.role),
                        ],
                      ),

                      SizedBox(height: Dimensions.height5),

                      // Bio (unchanged)
                      if (user.bio != null && user.bio!.isNotEmpty)
                        Padding(
                          padding: EdgeInsets.only(bottom: Dimensions.height10),
                          child: Text(
                            user.bio!,
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
                          // Follow Button
                          Expanded(
                            flex: 3,
                            child: _buildActionButton(
                              label: isFollowed ? 'Following' : 'Follow',
                              icon: isFollowed ? Icons.check : Icons.add,
                              isPrimary: !isFollowed,
                              onTap: () {
                                if (isFollowed) {
                                  userController.unfollowUser(user.id);
                                } else {
                                  userController.followUser(user.id);
                                }
                              },
                            ),
                          ),

                          SizedBox(width: Dimensions.width10),

                          // More Options Button
                          _buildIconButton(
                            icon: Icons.more_horiz,
                            onTap: () => _showOptionsBottomSheet(context, user),
                          ),
                        ],
                      )

                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          Icon(
            Icons.verified,
            size: 14,
            color: AppColors.primary,
          ),
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
    required VoidCallback onTap,
  }) {
    return Material(
      color: isPrimary ? AppColors.primary : Colors.grey[100],
      borderRadius: BorderRadius.circular(25),
      child: InkWell(
        onTap: onTap,
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
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.primary),
            const SizedBox(width: 10),
             Text('About Recommendations',style: TextStyle(fontSize: Dimensions.font20),),
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
      builder: (context) => PositionsBottomSheet(
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
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:  Icon(Iconsax.gift),
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
      height: MediaQuery.of(context).size.height * 0.85, // Takes up 85% of screen
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
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
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
                  )
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
                              Container(margin: const EdgeInsets.only(bottom: 20), child: _PositionNode('ST', currentPosition, onSelect)),
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
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
              border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
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
                )
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
