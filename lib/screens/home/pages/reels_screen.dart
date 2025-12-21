import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/post_controller.dart';
import '../../../models/post_model.dart';
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
  final PageController pageController = PageController();

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
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: (){
        controller.loadRecommendedPosts(currentType);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Obx(() {
          if (controller.posts.isEmpty) {
            controller.loadRecommendedPosts(currentType);;
          }

          return Stack(
            children: [
              // 1. The Vertical Feed
              PageView.builder(
                controller: pageController,
                scrollDirection: Axis.vertical,
                itemCount: controller.posts.length,
                onPageChanged: (index) => controller.onPageChanged(index),
                itemBuilder: (_, index) {
                  final post = controller.posts[index];
                  if (post.type == 'video') {
                    return ReelsVideoItem(
                        index: index,
                        post: post,
                        controller: controller
                    );
                  } else if (post.type == 'image') {
                    return _buildImageItem(post);
                  } else {
                    return _buildTextItem(post);
                  }
                },
              ),

              // 2. Top Tabs (Trials / Images / Videos)
              Positioned(
                top: MediaQuery.of(context).padding.top + 10,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // _tabBtn("Trials", "text"),
                    _tabBtn("Images", "image"),
                    _tabBtn("Videos", "video"),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // Simple Tab Switcher
  Widget _tabBtn(String label, String type) {
    final isActive = currentType == type;
    return GestureDetector(
      onTap: () {
        setState(() => currentType = type);
        controller.pauseAll();
        controller.loadRecommendedPosts(type);
        if(pageController.hasClients) pageController.jumpToPage(0);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white60,
            fontSize: 16,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Fallback for non-video posts
  Widget _buildImageItem(PostModel post) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(post.image?.url ?? "", fit: BoxFit.cover),
        ReelsInteractionOverlay(post: post),
      ],
    );
  }

  Widget _buildTextItem(PostModel post) {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          Center(
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Text(post.text ?? "",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24)
                ),
              )
          ),
          ReelsInteractionOverlay(post: post),
        ],
      ),
    );
  }
}