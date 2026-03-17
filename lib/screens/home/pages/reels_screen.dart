import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/reel_overlay.dart';
import '../../../widgets/reels_video_item.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  final PostController controller = Get.find<PostController>();
  // final PageController pageController = PageController();

  PostController postController = Get.find<PostController>();
  String currentType = "video";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.posts.isEmpty) {
        controller.loadRecommendedPosts(currentType);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        controller.loadRecommendedPosts(currentType);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {


          return Stack(
            children: [
              // 1. The Vertical Feed
              PageView.builder(
                controller: controller.reelsPageController,
                scrollDirection: Axis.vertical,
                itemCount: controller.posts.length,
                onPageChanged: (index) => controller.onPageChanged(index),
                itemBuilder: (_, index) {
                  final post = controller.posts[index];
                  if (post.type == 'video' || post.type == 'image') {
                    return ReelsVideoItem(
                      index: index,
                      post: post,
                      controller: controller,
                    );

                  }

                  return const SizedBox.shrink();
                },
              ),

              // 2. Top Tabs (Search Bar)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: Dimensions.width20,
                right: Dimensions.width20,
                child: ClipRRect(
                  // 1. Clip the blur effect to the rounded corners
                  borderRadius: BorderRadius.circular(Dimensions.radius15),
                  child: BackdropFilter(
                    // 2. The Blur Effect (Frosted Glass)
                    // This blurs the video behind the search bar, ensuring text readability
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height10,
                      ),
                      decoration: BoxDecoration(
                        // 3. Semi-transparent dark background
                        // This ensures white text pops even on bright white videos
                        color: Colors.black.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(Dimensions.radius15),
                        border: Border.all(
                          // 4. Subtle white border for contrast
                          color: Colors.white.withOpacity(0.2),
                          width: 1.5,
                        ),
                      ),
                      child: InkWell(
                        onTap: () {
                          postController.pauseAll();
                          Get.toNamed(AppRoutes.recommendedAccountsScreen);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            // 5. Icons and Text are always WHITE to contrast with the dark tint
                            Icon(
                                CupertinoIcons.search,
                                color: Colors.white,
                                size: Dimensions.iconSize24
                            ),
                            SizedBox(width: Dimensions.width15),
                            Text(
                              'Search...',
                              style: TextStyle(
                                fontSize: Dimensions.font16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9), // Slightly softer white
                                shadows: [
                                  // 6. Tiny drop shadow for extra legibility on chaotic backgrounds
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            InkWell(
                              onTap: () {},
                              child: Icon(
                                  Iconsax.people,
                                  size: Dimensions.iconSize24,
                                  color: Colors.white
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
