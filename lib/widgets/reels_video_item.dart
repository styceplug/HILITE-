import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/widgets/reel_overlay.dart';
import 'package:video_player/video_player.dart';

import '../controllers/post_controller.dart';
import '../models/post_model.dart';

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