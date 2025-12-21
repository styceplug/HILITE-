import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/reel_overlay.dart';
import 'package:video_player/video_player.dart';

import '../controllers/post_controller.dart';
import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../utils/colors.dart';

class ReelsVideoItem extends StatelessWidget {
  final int index;
  final PostModel post;
  final PostController controller;
  final String? tag; // <--- 1. ADD THIS

  const ReelsVideoItem({
    Key? key,
    required this.index,
    required this.post,
    required this.controller,
    this.tag, // <--- 2. ADD THIS
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.togglePlayPause(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: Thumbnail
          if (post.video?.thumbnailUrl != null)
            Image.network(post.video!.thumbnailUrl!, fit: BoxFit.cover)
          else
            Container(color: Colors.black),

          // LAYER 2: Video Player
          Obx(() {
            final isReady = controller.initializedIndexes.contains(index);
            final videoCtrl = controller.videoControllers[index];

            if (!isReady || videoCtrl == null) return const SizedBox.shrink();

            return FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: videoCtrl.value.size.width,
                height: videoCtrl.value.size.height,
                child: VideoPlayer(videoCtrl),
              ),
            );
          }),

          // LAYER 3: Play/Pause Icon
          GetBuilder<PostController>(
            id: 'overlay_$index',
            tag: tag, // <--- 3. PASS THE TAG HERE
            builder: (_) {
              final videoCtrl = controller.videoControllers[index];
              if (videoCtrl == null || !videoCtrl.value.isInitialized) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              return videoCtrl.value.isPlaying
                  ? const SizedBox.shrink()
                  : const Center(child: Icon(Icons.play_arrow, size: 60, color: Colors.white54));
            },
          ),

          // LAYER 4: UI Overlay
          ReelsInteractionOverlay(post: post),
        ],
      ),
    );
  }
}


class ProfileReelsPlayer extends StatefulWidget {
  final List<PersonalPostModel> videos;
  final int initialIndex;

  const ProfileReelsPlayer({
    Key? key,
    required this.videos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<ProfileReelsPlayer> createState() => _ProfileReelsPlayerState();
}

class _ProfileReelsPlayerState extends State<ProfileReelsPlayer> {
  late PostController _profileController;
  final String _controllerTag = 'profile_reels'; // Unique ID for this screen
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);

    // 1. Create a NEW, TAGGED instance of PostController just for this screen
    // This ensures we don't mess up the Home Screen feed.
    _profileController = Get.put(
        PostController(postRepo: Get.find()),
        tag: _controllerTag
    );

    // 2. Convert PersonalPostModel -> PostModel and load into controller
    final convertedPosts = widget.videos.map((p) => _convertToPostModel(p)).toList();
    _profileController.posts.assignAll(convertedPosts);

    // 3. Start playing the initial video
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _profileController.onPageChanged(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    // 4. Clean up this specific controller to free memory
    Get.delete<PostController>(tag: _controllerTag);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _profileController.posts.length,
            onPageChanged: (index) => _profileController.onPageChanged(index),
            itemBuilder: (_, index) {
              return ReelsVideoItem(
                index: index,
                post: _profileController.posts[index],
                controller: _profileController,
                tag: _controllerTag, // Important: Pass the tag!
              );
            },
          ),

          // Back Button
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),
        ],
      ),
    );
  }

// ✅ FIXED: Accurately maps PersonalPostModel -> PostModel
  PostModel _convertToPostModel(PersonalPostModel personal) {
    // 1. Get Current User (Me)
    final me = Get.find<UserController>().user.value;

    // 2. Create Author object from UserModel
    // Note: If 'me' is null, we provide safe defaults
    final author = Author(
      id: me?.id ?? '',
      username: me?.username ?? 'Unknown',
      profilePicture: me?.profilePicture ?? '',
    );

    // 3. Create ContentDetails (Video) object
    // Note: PersonalPostModel stores thumbnail in 'thumbnail' but ContentDetails expects 'thumbnailUrl'
    final videoContent = ContentDetails(
      url: personal.mediaUrl,
      title: personal.text, // Use text as title fallback
      description: personal.text,
      thumbnailUrl: personal.thumbnail,
    );

    // 4. Return the full PostModel
    return PostModel(
      id: personal.id ?? '',
      type: personal.type ?? 'video',
      text: personal.text,
      author: author,

      // Map the video content
      video: videoContent,

      // PersonalPostModel doesn't have these, so we use empty defaults
      // This fixes the "getter not defined" errors
      likes: [],
      comments: [],
      isLiked: false,

      // If your PostModel has an 'image' field, we can leave it null for video posts
      image: null,
    );
  }
}