import 'dart:async';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/post_controller.dart';
import '../../../routes/routes.dart';
import '../../../utils/dimensions.dart';
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
        controller.activatePlayback();
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
    unawaited(controller.deactivatePlayback());
    super.dispose();
  }

  // 1. Handle App Lifecycle (Phone calls, Minimizing)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(controller.deactivatePlayback());
    } else if (state == AppLifecycleState.resumed && _isScreenVisible) {
      _resumeVideo();
    }
  }

  void _resumeVideo() {
    // Logic to play the current page index when returning
    int currentIndex =
        controller.reelsPageController.hasClients
            ? controller.reelsPageController.page?.round() ?? 0
            : 0;
    controller.activatePlayback();
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
            unawaited(controller.deactivatePlayback());
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
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
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
      // right: 20,
      child: Hero(
        tag: 'search_bar',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  unawaited(controller.deactivatePlayback());
                  Get.toNamed(AppRoutes.recommendedAccountsScreen);
                },
                child: IntrinsicWidth(
                  child: Container(
                    // width: Dimensions.width50,
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width10,
                      vertical: Dimensions.height10*0.7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                     CupertinoIcons.search,
                     color: Colors.white.withOpacity(0.4),
                     size: Dimensions.iconSize30,
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
