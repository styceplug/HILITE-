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

  const ReelsVideoItem({
    Key? key,
    required this.index,
    required this.post,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.togglePlayPause(index),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // LAYER 1: The Thumbnail (Placeholder)
          // This shows INSTANTLY while video loads in background
          if (post.video?.thumbnailUrl != null)
            Image.network(
              post.video!.thumbnailUrl!,
              fit: BoxFit.cover,
            )
          else
            Container(color: Colors.black),
      
          // LAYER 2: The Actual Video Player
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
      
          // LAYER 3: Play/Pause Icon Overlay
      
          GetBuilder<PostController>(
            id: 'overlay_$index',
            builder: (_) {
              final videoCtrl = controller.videoControllers[index];
      
              // Check if controller exists AND is initialized before accessing .value
              if (videoCtrl == null || !videoCtrl.value.isInitialized) {
                return const Center(child: Icon(Icons.downloading, size: 60, color: Colors.white54));
              }
      
              final isPlaying = videoCtrl.value.isPlaying;
      
              if (isPlaying) return const SizedBox.shrink();
      
              // Show the pause icon only if it's paused or stopped
              return const Center(
                child: Icon(Icons.play_arrow, size: 60, color: Colors.white54),
              );
            },
          ),
      
          // LAYER 4: The UI Overlay (Text, Buttons, Gradient)
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
  late PageController _pageController;
  VideoPlayerController? _videoController;
  int _currentIndex = 0;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    _initializeVideo(widget.videos[_currentIndex].mediaUrl ?? '');
  }

  // 🎥 Logic to init video
  void _initializeVideo(String url) async {
    // Dispose previous controller if exists
    _videoController?.dispose();
    _videoController = null; // Reset to avoid UI flickering

    if (url.isEmpty) return;

    // Create new controller
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    _videoController!.play();
    _videoController!.setLooping(true);

    if (mounted) {
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    // Load the next video when user swipes
    _initializeVideo(widget.videos[index].mediaUrl ?? '');
  }

  void _togglePlay() {
    if (_videoController == null) return;
    setState(() {
      if (_videoController!.value.isPlaying) {
        _videoController!.pause();
        _isPlaying = false;
      } else {
        _videoController!.play();
        _isPlaying = true;
      }
    });
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. The Swipeable Page View
          PageView.builder(
            scrollDirection: Axis.vertical,
            controller: _pageController,
            itemCount: widget.videos.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              // If this is the current page, show the video
              if (index == _currentIndex && _videoController != null && _videoController!.value.isInitialized) {
                return GestureDetector(
                  onTap: _togglePlay,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Video Aspect Ratio
                      SizedBox.expand(
                        child: FittedBox(
                          fit: BoxFit.cover,
                          child: SizedBox(
                            width: _videoController!.value.size.width,
                            height: _videoController!.value.size.height,
                            child: VideoPlayer(_videoController!),
                          ),
                        ),
                      ),
                      // Play/Pause Icon Overlay
                      if (!_isPlaying)
                        const Icon(Icons.play_arrow, size: 60, color: Colors.white54),
                    ],
                  ),
                );
              }

              // While loading or if not current page, show thumbnail
              return Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.videos[index].thumbnail != null)
                    Image.network(widget.videos[index].thumbnail!, fit: BoxFit.cover)
                  else
                    Container(color: Colors.black),
                  const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                ],
              );
            },
          ),

          // 2. Back Button (Top Left)
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ),

          // 3. Simple Info Overlay (Bottom)
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "@${Get.find<UserController>().user.value?.username ?? 'me'}",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.videos[_currentIndex].text ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                SizedBox(height: Dimensions.height70),
              ],
            ),
          )
        ],
      ),
    );
  }
}