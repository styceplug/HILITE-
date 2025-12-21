import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:iconsax/iconsax.dart';

import '../models/post_model.dart';
import '../utils/colors.dart';
import 'gift_bottom_modal.dart';

class ReelsInteractionOverlay extends StatelessWidget {
  final PostModel post;

  const ReelsInteractionOverlay({Key? key, required this.post})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    PostController postController = Get.find<PostController>();

    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width15,
        0,
        Dimensions.width15,
        Dimensions.height10,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black54, Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.5],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // LEFT SIDE: Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.author?.username.capitalizeFirst ?? '',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: Dimensions.font22,
                      ),
                    ),

                    SizedBox(height: Dimensions.height5),

                    Builder(
                      builder: (context) {
                        String? descriptionText;

                        // A. Prioritize the main post 'text' field if it exists
                        if (post.text != null && post.text!.isNotEmpty) {
                          descriptionText = post.text;
                        }
                        // B. If no main 'text', check the content-specific description
                        else if (post.type == 'video' &&
                            post.video?.description != null) {
                          descriptionText = post.video!.description;
                        } else if (post.type == 'image' &&
                            post.image?.description != null) {
                          descriptionText = post.image!.description;
                        }

                        // 3. Display the description if found
                        if (descriptionText != null &&
                            descriptionText.isNotEmpty) {
                          return Text(
                            descriptionText,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: Dimensions.font16,
                            ),
                          );
                        }

                        // Return an empty SizedBox if no text is available
                        return const SizedBox.shrink();
                      },
                    ),
                    SizedBox(height: Dimensions.height150),
                  ],
                ),
              ),

              // RIGHT SIDE: Interaction Buttons
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Profile Pic
                  _ProfileAvatar(
                    url: post.author?.profilePicture,
                    argument: post.author?.id,
                  ),
                  const SizedBox(height: 20),

                  // Likes
                  Obx(() {
                    final currentPost =
                        postController.posts.firstWhereOrNull(
                          (p) => p.id == post.id,
                        ) ??
                        post;
                    final bool isLiked = currentPost.isLiked;

                    return GestureDetector(
                      onTap: () => postController.toggleLike(currentPost.id),
                      child: _InteractionIcon(
                        icon: isLiked ? Iconsax.heart5 : Iconsax.heart,
                        // Filled vs. Outline
                        label: "${currentPost.likes.length}",
                        color:
                            isLiked
                                ? Colors.red
                                : Colors.white, // Change color if liked
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  Obx(() {
                    // Find the updated post model from the observable list.
                    final currentPost =
                        postController.posts.firstWhereOrNull(
                          (p) => p.id == post.id,
                        ) ??
                        post;

                    return GestureDetector(
                      onTap: () {
                        // 🚀 Call the function that handles fetching and displaying the UI
                        postController.showCommentsForPost(currentPost.id);
                      },
                      child: _InteractionIcon(
                        icon: Iconsax.message,
                        label: "${currentPost.comments.length}",
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        GiftSelectionBottomSheet(
                          recipientId: post.author?.id ?? "",
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: _InteractionIcon(
                      icon: Icons.card_giftcard,
                      label: "Gift",
                      color: Colors.amber,
                    ),
                  ),
                  SizedBox(height: Dimensions.height150),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Helper Widgets for clean code
class _InteractionIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InteractionIcon({
    Key? key,
    required this.icon,
    required this.label,
    this.color = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: Dimensions.iconSize30 * 1.2),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? url;
  final String? argument;

  const _ProfileAvatar({Key? key, this.url, this.argument}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (argument != null && argument!.isNotEmpty) {
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': argument},
          );
          PostController postController = Get.find<PostController>();
          postController.pauseAll();
        } else {
          print("Cannot navigate: Author ID is missing.");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: CircleAvatar(
          radius: Dimensions.radius20 * 1.1,
          backgroundImage:
              (url != null && url!.isNotEmpty) ? NetworkImage(url!) : null,
          child:
              (url == null || url!.isEmpty) ? const Icon(Icons.person) : null,
        ),
      ),
    );
  }
}
