import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RelationshipScreen extends StatefulWidget {
  final String title;
  final String type;
  final String? targetId;

  const RelationshipScreen({
    super.key,
    required this.title,
    required this.type,
    this.targetId
  });

  @override
  State<RelationshipScreen> createState() => _RelationshipScreenState();
}

class _RelationshipScreenState extends State<RelationshipScreen> {
  final UserController userController = Get.find<UserController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getRelationshipUsers(widget.type, targetId: widget.targetId);
      _searchController.clear();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030A1B), // Premium Dark Background
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        title: widget.title,
        leadingIcon: const BackButton(color: Colors.white),
      ),
      body: GetBuilder<UserController>(
        builder: (controller) {


          bool isInitialLoad = controller.relationshipList.isEmpty && _searchController.text.isEmpty;
          return Column(
            children: [
              // --- Search Bar Area ---
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05), // Glassmorphism search
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.title.toLowerCase()}',
                      hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: Dimensions.font14
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) {
                      controller.searchRelationship(val);
                    },
                  ),
                ),
              ),

              // --- List Area ---
              Expanded(
                child: Skeletonizer(
                  enabled: isInitialLoad,
                  child: isInitialLoad
                      ? _buildSkeletonList() // Shimmering loading state
                      : controller.relationshipList.isEmpty && _searchController.text.isEmpty
                      ? _buildEmptyState()
                      : controller.filteredRelationshipList.isEmpty
                      ? _buildNoSearchResults()
                      : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
                    itemCount: controller.filteredRelationshipList.length,
                    itemBuilder: (context, index) {
                      UserModel user = controller.filteredRelationshipList[index];
                      return _buildUserTile(user);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- SKELETONIZER LOADER ---
  Widget _buildSkeletonList() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
      itemCount: 8, // Dummy count for shimmer
      itemBuilder: (context, index) {
        return Container(
          padding: EdgeInsets.only(bottom: Dimensions.height20),
          child: Row(
            children: [
              Container(
                height: Dimensions.height10 * 5,
                width: Dimensions.height10 * 5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(width: Dimensions.width15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 16,
                      width: Dimensions.screenWidth * 0.4,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 12,
                      width: Dimensions.screenWidth * 0.25,
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 24,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.05),
            ),
            child: Icon(Icons.people_outline, size: 50, color: Colors.white.withOpacity(0.2)),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            "No ${widget.title.toLowerCase()} yet",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "When users join here, they'll show up.",
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 10),
          Text(
            "No users found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      padding: EdgeInsets.only(bottom: Dimensions.height15),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': user.id},
          );
        },
        highlightColor: Colors.white.withOpacity(0.05),
        splashColor: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0), // Touch target padding
          child: Row(
            children: [
              // 1. The Avatar Widget
              ListItemAvatar(
                imageUrl: user.profilePicture,
                size: Dimensions.height10 * 5,
              ),

              SizedBox(width: Dimensions.width15),

              // 2. Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      user.name.capitalizeFirst ?? "User",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '@${user.username}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.5),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: Dimensions.width10),

              // 3. Trailing Action
              _buildRoleBadge(user.role),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'player':
        badgeColor = const Color(0xFF2563EB).withOpacity(0.15); // Primary Blue
        textColor = const Color(0xFF60A5FA); // Lighter blue for dark mode readability
        break;
      case 'club':
        badgeColor = Colors.orange.withOpacity(0.15);
        textColor = Colors.orangeAccent;
        break;
      case 'agent':
        badgeColor = Colors.purple.withOpacity(0.15);
        textColor = Colors.purpleAccent;
        break;
      default: // fan
        badgeColor = Colors.white.withOpacity(0.1);
        textColor = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20), // Pill shape
        border: Border.all(color: textColor.withOpacity(0.3)), // Subtle glow border
      ),
      child: Text(
        role.capitalizeFirst ?? '',
        style: TextStyle(
          fontSize: 11,
          color: textColor,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class ListItemAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;

  const ListItemAvatar({
    super.key,
    required this.imageUrl,
    this.size = 50.0, // Default size for lists
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200], // Background for transparent images
        border: Border.all(
          color: Colors.grey[300]!, // Subtle border
          width: 1,
        ),
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    return Image.network(
      imageUrl!,
      fit: BoxFit.cover,
      width: size,
      height: size,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: SizedBox(
            width: size * 0.4,
            height: size * 0.4,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Icon(
        Icons.person,
        size: size * 0.5,
        color: Colors.grey[400],
      ),
    );
  }
}
