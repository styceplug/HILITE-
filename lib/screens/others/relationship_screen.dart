import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/user_controller.dart';
import '../../models/user_model.dart';
import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/profile_avatar.dart';

class RelationshipScreen extends StatefulWidget {
  final String title;
  final String type;

  const RelationshipScreen({
    super.key,
    required this.title,
    required this.type
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
      userController.getRelationshipUsers(widget.type);
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
      backgroundColor: Colors.white,
      appBar: CustomAppbar(
        title: widget.title,
        leadingIcon: const BackButton(color: Colors.black),
        // Optional: Add a refresh action or count
      ),
      body: GetBuilder<UserController>(
        builder: (controller) {


          // 2️⃣ Empty State
          if (controller.relationshipList.isEmpty) {
            return _buildEmptyState();
          }

          // 3️⃣ Content
          return Column(
            children: [
              // Search Bar Area
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height10,
                ),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width15),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.title.toLowerCase()}',
                      hintStyle: TextStyle(
                          color: Colors.grey[500],
                          fontSize: Dimensions.font14
                      ),
                      border: InputBorder.none,
                      icon: Icon(Icons.search, color: Colors.grey[500]),
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (val) {
                      controller.searchRelationship(val);
                    },
                  ),
                ),
              ),

              // The List
              Expanded(
                child: controller.filteredRelationshipList.isEmpty
                    ? _buildNoSearchResults() // New UI for "No match found"
                    : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                  // ✅ USE FILTERED LIST
                  itemCount: controller.filteredRelationshipList.length,
                  itemBuilder: (context, index) {
                    UserModel user = controller.filteredRelationshipList[index];
                    return _buildUserTile(user);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[50],
            ),
            child: Icon(Icons.people_outline, size: 50, color: Colors.grey[400]),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            "No ${widget.title.toLowerCase()} yet",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 5),
          Text(
            "When users join here, they'll show up.",
            style: TextStyle(color: Colors.grey[500]),
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
          Icon(Icons.search_off, size: 50, color: Colors.grey[300]),
          SizedBox(height: 10),
          Text(
            "No users found",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserTile(UserModel user) {
    return Container(
      // Removed fixed height to allow dynamic sizing if text wraps
      padding: EdgeInsets.only(bottom: Dimensions.height20),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': user.id},
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // 1. The New Avatar Widget
            ListItemAvatar(
              imageUrl: user.profilePicture,
              size: Dimensions.height10 * 5,
            ),

            SizedBox(width: Dimensions.width15),

            // 2. Info (Wrapped in Expanded to prevent overflow)
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
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '@${user.username}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
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
    );
  }

  Widget _buildRoleBadge(String role) {
    Color badgeColor;
    Color textColor;

    switch (role.toLowerCase()) {
      case 'player':
        badgeColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        break;
      case 'club':
        badgeColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      case 'agent':
        badgeColor = Colors.purple.withOpacity(0.1);
        textColor = Colors.purple;
        break;
      default: // fan
        badgeColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey[700]!;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20), // Pill shape
      ),
      child: Text(
        role.capitalizeFirst ?? '',
        style: TextStyle(
          fontSize: 12,
          color: textColor,
          fontWeight: FontWeight.w600,
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
