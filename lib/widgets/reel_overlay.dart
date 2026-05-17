import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/models/user_model.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

import '../models/post_model.dart';
import '../utils/colors.dart';
import 'gift_bottom_modal.dart';

class ReelsInteractionOverlay extends StatelessWidget {
  final PostModel post;
  final PostController controller;

  const ReelsInteractionOverlay({
    Key? key,
    required this.post,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserController userController = Get.find<UserController>();

    // 1. Generate the Creator Info Text safely
    String creatorInfo = '';
    if (post.author != null) {
      creatorInfo = _buildCreatorInfo(post.author!);
    }

    return Container(
      padding: EdgeInsets.fromLTRB(
        Dimensions.width15,
        0,
        Dimensions.width15,
        Dimensions.height10,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.transparent],
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.0, 0.6],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // ----------------------------------------------------
              // LEFT SIDE: Details
              // ----------------------------------------------------
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Username
                    InkWell(
                      onTap: () async {
                        final authorId = post.author?.id ?? post.authorId;
                        final currentUserId = userController.user.value?.id;

                        if (authorId != null &&
                            authorId.isNotEmpty &&
                            authorId != currentUserId) {
                          controller.deactivatePlayback();
                          Get.toNamed(
                            AppRoutes.othersProfileScreen,
                            arguments: {'targetId': authorId},
                          );
                        }
                      },
                      child: Text(
                        post.author?.name ?? 'Unknown',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: Dimensions.font20,
                          shadows: const [
                            Shadow(color: Colors.black45, blurRadius: 4),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height5),

                    // 2. Description
                    Builder(
                      builder: (context) {
                        String? descriptionText;
                        if (post.text != null && post.text!.isNotEmpty) {
                          descriptionText = post.text;
                        } else if (post.type == 'video' &&
                            post.video?.description != null) {
                          descriptionText = post.video!.description;
                        } else if (post.type == 'image' &&
                            post.image?.description != null) {
                          descriptionText = post.image!.description;
                        }

                        if (descriptionText != null &&
                            descriptionText.isNotEmpty) {
                          return Text(
                            descriptionText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: Dimensions.font15,
                              height: 1.3,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    // 4. Creator Info Pill (ONLY SHOW IF TEXT IS NOT EMPTY)
                    if (creatorInfo.isNotEmpty) ...[
                      SizedBox(height: Dimensions.height10),
                      Row(
                        children: [
                          Container(
                            child: Text(
                              creatorInfo,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    // 3. Tags
                    if (post.tags.isNotEmpty) ...[
                      SizedBox(height: Dimensions.height10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.width10,
                          vertical: Dimensions.height5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            Dimensions.radius10
                          ),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children:
                              post.tags
                                  .map(
                                    (tag) => Text(
                                      '#$tag',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                      ),
                    ],



                    SizedBox(height: Dimensions.height150),
                  ],
                ),
              ),

              // ----------------------------------------------------
              // RIGHT SIDE: Interaction Buttons
              // ----------------------------------------------------
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileAvatar(
                    url: post.author?.profilePicture,
                    argument: post.author?.id ?? post.authorId,
                    controller: controller,
                  ),
                  const SizedBox(height: 20),

                  Obx(() {
                    final currentPost =
                        controller.posts.firstWhereOrNull(
                          (p) => p.id == post.id,
                        ) ??
                        post;
                    final bool isLiked = currentPost.isLiked;

                    return GestureDetector(
                      onTap: () => controller.toggleLike(currentPost.id),
                      child: _InteractionIcon(
                        icon: isLiked ? Iconsax.heart5 : Iconsax.heart,
                        label: "${currentPost.likes.length}",
                        color: isLiked ? Colors.red : Colors.white,
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  Obx(() {
                    final currentPost =
                        controller.posts.firstWhereOrNull(
                          (p) => p.id == post.id,
                        ) ??
                        post;
                    return GestureDetector(
                      onTap:
                          () => controller.showCommentsForPost(currentPost.id),
                      child: _InteractionIcon(
                        icon: Iconsax.message,
                        label: "${currentPost.comments.length}",
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  Obx(() {
                    final isBookmarked = controller.isPostBookmarked(post.id);
                    return InkWell(
                      onTap: () => controller.toggleBookmark(post.id),
                      child: _InteractionIcon(
                        icon:
                            isBookmarked
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                        color: isBookmarked ? AppColors.white : Colors.white,
                        label: 'Save',
                      ),
                    );
                  }),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      controller.pauseAll();
                      final link = "https://api.hiliteapp.net/post/${post.id}";
                      Share.share(
                        'Check out this on Hilite! $link',
                        subject: 'Watch this on Hilite',
                      );
                    },
                    child: const _InteractionIcon(
                      icon: Iconsax.send_1,
                      label: "Share",
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),

                  GestureDetector(
                    onTap: () {
                      Get.bottomSheet(
                        GiftSelectionBottomSheet(
                          recipientId: post.author?.id ?? post.authorId ?? "",
                        ),
                        isScrollControlled: true,
                      );
                    },
                    child: const _InteractionIcon(
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


  String _buildCreatorInfo(UserModel user) {
    String role = user.role.toLowerCase();


    if (role.isEmpty) {
      if (user.playerDetails != null)
        role = 'player';
      else if (user.clubDetails != null)
        role = 'club';
      else if (user.agentDetails != null)
        role = 'agent';
      else
        role = 'fan';
    }

    if (role == 'player' && user.playerDetails != null) {
      final p = user.playerDetails!;
      final age = _calculateAge(p.dob);
      final ageStr = age != null ? '$age yrs' : '';


      String footStr =
          p.preferredFoot.isNotEmpty
              ? '${p.preferredFoot[0].toUpperCase()}${p.preferredFoot.substring(1)} Foot'
              : '';

      final pos = p.position.isNotEmpty ? p.position.toUpperCase() : '';

      return [pos, ageStr, footStr].where((s) => s.isNotEmpty).join(' • ');
    } else if (role == 'club' && user.clubDetails != null) {
      final c = user.clubDetails!;
      String typeStr =
          c.clubType.isNotEmpty
              ? '${c.clubType[0].toUpperCase()}${c.clubType.substring(1)}'
              : '';

      return [
        typeStr,
        c.yearFounded.isNotEmpty ? 'Est. ${c.yearFounded}' : '',
      ].where((s) => s.isNotEmpty).join(' • ');
    } else if (role == 'agent' && user.agentDetails != null) {
      final a = user.agentDetails!;
      return [
        a.agencyName,
        a.experience.isNotEmpty ? '${a.experience} Exp' : '',
      ].where((s) => s.isNotEmpty).join(' • ');
    }


    return role.isNotEmpty
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : 'Fan Profile';
  }

  int? _calculateAge(DateTime? dob) {
    if (dob == null) return null;
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day))
      age--;
    return age;
  }
}

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
  final PostController controller;

  const _ProfileAvatar({
    Key? key,
    this.url,
    this.argument,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (argument != null && argument!.isNotEmpty) {
          unawaited(controller.deactivatePlayback());
          Get.toNamed(
            AppRoutes.othersProfileScreen,
            arguments: {'targetId': argument},
          );
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
