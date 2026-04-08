import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';

import '../../models/post_model.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/reels_video_item.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen> {
  final PostController postController = Get.find<PostController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      postController.getBookmarks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(
        title: "Saved Posts",
        leadingIcon: BackButton(),
      ),
      body: GetBuilder<PostController>(
        builder: (controller) {

          if (controller.bookmarkList.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 60, color: Colors.grey[300]),
                  const SizedBox(height: 10),
                  Text("No saved posts yet", style: TextStyle(color: Colors.grey[500])),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: EdgeInsets.all(Dimensions.width15),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1, // Square tiles
            ),
            itemCount: controller.bookmarkList.length,
            itemBuilder: (context, index) {
              final post = controller.bookmarkList[index];
              return GestureDetector(
                onTap: () {
                  // Navigate to the player with the full list and clicked index
                  Get.to(() => BookmarkPlayerScreen(
                    posts: controller.bookmarkList,
                    initialIndex: index,
                  ));
                },
                child: _buildGridTile(post),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildGridTile(PostModel post) {
    // 1. VIDEO
    if (post.type == 'video') {
      return Stack(
        fit: StackFit.expand,
        children: [
          Container(color: Colors.black),
          if (post.video?.thumbnailUrl != null)
            Image.network(post.video!.thumbnailUrl!, fit: BoxFit.cover),
          const Center(
            child: Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
          ),
        ],
      );
    }
    // 2. IMAGE
    else if (post.type == 'image') {
      return Image.network(
        post.image?.url ?? '',
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
      );
    }
    // 3. TEXT
    else {
      return Container(
        padding: const EdgeInsets.all(8),
        color: Colors.grey[200],
        child: Center(
          child: Text(
            post.text ?? '',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
  }
}


class BookmarkPlayerScreen extends StatefulWidget {
  final List<PostModel> posts;
  final int initialIndex;

  const BookmarkPlayerScreen({
    super.key,
    required this.posts,
    required this.initialIndex
  });

  @override
  State<BookmarkPlayerScreen> createState() => _BookmarkPlayerScreenState();
}

class _BookmarkPlayerScreenState extends State<BookmarkPlayerScreen> {
  late final PostController controller;
  late final String _controllerTag;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    _controllerTag =
        'bookmark_player_${DateTime.now().microsecondsSinceEpoch}';
    controller = Get.put(
      PostController(postRepo: Get.find()),
      tag: _controllerTag,
    );
    pageController = PageController(initialPage: widget.initialIndex);

    controller.posts.assignAll(widget.posts);

    // 3. Initialize the first video (the one tapped)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.activatePlayback();
      controller.onPageChanged(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    // Stop all videos when leaving this screen
    unawaited(controller.deactivatePlayback());
    unawaited(controller.disposeAllControllers());
    Get.delete<PostController>(tag: _controllerTag);
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            scrollDirection: Axis.vertical,
            itemCount: widget.posts.length,
            onPageChanged: (index) => controller.onPageChanged(index),
            itemBuilder: (_, index) {
              final post = widget.posts[index];
              // Reuse your existing ReelsVideoItem
              return ReelsVideoItem(
                index: index,
                post: post,
                controller: controller,
                tag: _controllerTag,
              );
            },
          ),

          // Back Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black54,
              child: BackButton(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
