import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/reel_overlay.dart';
import 'package:video_player/video_player.dart';

import '../controllers/post_controller.dart';
import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../utils/colors.dart';

import 'dart:ui'; // For blur effect if needed
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';


class ReelsVideoItem extends StatefulWidget {
  final int index;
  final PostModel post;
  final PostController controller;
  final String? tag;

  const ReelsVideoItem({
    Key? key,
    required this.index,
    required this.post,
    required this.controller,
    this.tag,
  }) : super(key: key);

  @override
  State<ReelsVideoItem> createState() => _ReelsVideoItemState();
}

class _ReelsVideoItemState extends State<ReelsVideoItem> with SingleTickerProviderStateMixin {
  bool _isSpeedingUp = false;
  bool _isDragging = false;

  late AnimationController _speedAnimController;
  late Animation<double> _speedOpacity;

  @override
  void initState() {
    super.initState();
    _speedAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _speedOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(_speedAnimController);
  }

  @override
  void dispose() {
    _speedAnimController.dispose();
    super.dispose();
  }

  void _startSpeedUp(TapDownDetails details, VideoPlayerController videoCtrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Right side of screen triggers speed up
    if (details.globalPosition.dx > screenWidth * 0.6) {
      videoCtrl.setPlaybackSpeed(2.0);
      setState(() => _isSpeedingUp = true);
      _speedAnimController.forward();
    }
  }

  void _endSpeedUp(VideoPlayerController videoCtrl) {
    if (_isSpeedingUp) {
      videoCtrl.setPlaybackSpeed(1.0);
      setState(() => _isSpeedingUp = false);
      _speedAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      id: 'video_item_${widget.index}',
      tag: widget.tag,
      builder: (controller) {
        final videoCtrl = widget.controller.videoControllers[widget.index];
        final isReady = widget.controller.initializedIndexes.contains(widget.index);

        // ✅ FIX: GestureDetector is now the ROOT widget
        // This ensures it catches taps even if the video is visually behind other things.
        return GestureDetector(
          behavior: HitTestBehavior.opaque, // Ensures taps are caught
          onTap: () => widget.controller.togglePlayPause(widget.index),
          onTapDown: (details) {
            if (isReady && videoCtrl != null) _startSpeedUp(details, videoCtrl);
          },
          onTapUp: (_) {
            if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
          },
          onTapCancel: () {
            if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
          },
          onLongPressEnd: (_) {
            if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
          },

          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. THUMBNAIL
              if (widget.post.video?.thumbnailUrl != null)
                Image.network(widget.post.video!.thumbnailUrl!, fit: BoxFit.cover)
              else
                Container(color: Colors.black),

              // 2. VIDEO PLAYER
                if (isReady && videoCtrl != null && videoCtrl.value.isInitialized)
                  FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: videoCtrl.value.size.width,
                    height: videoCtrl.value.size.height,
                    child: VideoPlayer(videoCtrl),
                  ),
                ),

              // 3. "2X SPEED" OVERLAY
              if (isReady)
                Positioned(
                  top: 50,
                  right: 0,
                  left: 0,
                  child: FadeTransition(
                    opacity: _speedOpacity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.fast_forward_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text("2x Speed", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // 4. PLAY/PAUSE ICON (Animated)
              if (isReady && videoCtrl != null)
                Center(
                  child: ValueListenableBuilder(
                    valueListenable: videoCtrl,
                    builder: (context, VideoPlayerValue value, child) {
                      if (_isSpeedingUp || _isDragging) return const SizedBox.shrink();

                      if (!value.isPlaying && !value.isBuffering) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(15),
                          child: const Icon(Icons.play_arrow_rounded, size: 50, color: Colors.white),
                        );
                      }
                      if (value.isBuffering) {
                        return const CircularProgressIndicator(color: Colors.white);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),

              // 5. INTERACTION OVERLAY
              // (Buttons like "Like", "Comment" inside this widget will still work
              // because they sit on top and consume their own touch events)
              if (!_isDragging)
                ReelsInteractionOverlay(post: widget.post),

              // 6. PROGRESS BAR
              if (isReady && videoCtrl != null)
                Positioned(
                  bottom: Dimensions.bottomNavIconHeight+Dimensions.height10*9,
                  left: 0,
                  right: 0,
                  child: _buildProgressBar(videoCtrl),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final duration = value.duration.inMilliseconds;
        final position = value.position.inMilliseconds;
        double max = duration.toDouble();
        double current = position.toDouble();

        if (current > max) current = max;
        if (max <= 0) max = 1.0;

        // ✅ FIX: Corrected SliderThemeData error
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withOpacity(0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withOpacity(0.4),
          ),
          child: Slider(
            value: current,
            min: 0.0,
            max: max,
            onChangeStart: (_) {
              setState(() => _isDragging = true);
              controller.pause();
            },
            onChangeEnd: (_) {
              setState(() => _isDragging = false);
              controller.play();
            },
            onChanged: (val) {
              controller.seekTo(Duration(milliseconds: val.toInt()));
            },
          ),
        );
      },
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