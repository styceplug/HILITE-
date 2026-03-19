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

import 'package:visibility_detector/visibility_detector.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({Key? key}) : super(key: key);

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> with WidgetsBindingObserver {
  final PostController controller = Get.find<PostController>();
  final String currentType = "video";
  bool _isScreenVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Listen for app backgrounding

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.posts.isEmpty) {
        controller.loadRecommendedPosts(currentType);
      } else {
        // If returning to this tab, resume the current video
        _resumeVideo();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // Important: We don't necessarily delete the controller here
    // if it's a main-tab controller, but we MUST stop the hardware.
    controller.pauseAll();
    super.dispose();
  }

  // 1. Handle App Lifecycle (Phone calls, Minimizing)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      controller.pauseAll();
    } else if (state == AppLifecycleState.resumed && _isScreenVisible) {
      _resumeVideo();
    }
  }

  void _resumeVideo() {
    // Logic to play the current page index when returning
    int currentIndex = controller.reelsPageController.hasClients
        ? controller.reelsPageController.page?.round() ?? 0
        : 0;
    controller.playVideo(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // 2. Wrap the entire body in VisibilityDetector
      // This handles Tab Switching (Home -> Profile)
      body: VisibilityDetector(
        key: const Key('reels-screen-key'),
        onVisibilityChanged: (visibilityInfo) {
          _isScreenVisible = visibilityInfo.visibleFraction > 0.5;
          if (!_isScreenVisible) {
            controller.pauseAll();
          } else {
            _resumeVideo();
          }
        },
        child: RefreshIndicator(
          onRefresh: () async {
            await controller.loadRecommendedPosts(currentType);
          },
          child: Obx(() {
            if (controller.posts.isEmpty && controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            return Stack(
              children: [
                PageView.builder(
                  controller: controller.reelsPageController,
                  scrollDirection: Axis.vertical,
                  itemCount: controller.posts.length,
                  onPageChanged: (index) => controller.onPageChanged(index),
                  itemBuilder: (_, index) {
                    return ReelsVideoItem(
                      index: index,
                      post: controller.posts[index],
                      controller: controller,
                    );
                  },
                ),
                _buildTopSearchBar(context),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTopSearchBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 20,
      right: 20,
      child: Hero(
        tag: 'search_bar', // Added Hero for smooth transition to search screen
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Material( // Wrap in Material to fix text rendering in Hero
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  controller.pauseAll();
                  Get.toNamed(AppRoutes.recommendedAccountsScreen);
                },
                child: Container(
                  padding:  EdgeInsets.symmetric(horizontal: 20, vertical: Dimensions.height5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(CupertinoIcons.search, color: Colors.white, size: 24),
                      const SizedBox(width: 15),
                      const Text('Search...', style: TextStyle(color: Colors.white)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Iconsax.people, color: Colors.white),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      )
                    ],
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
