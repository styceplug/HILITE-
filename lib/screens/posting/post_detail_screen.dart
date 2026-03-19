import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/app_loading_overlay.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:video_player/video_player.dart';

import '../../utils/colors.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PostController postController = Get.find<PostController>();
  late TextEditingController _descController;
  VideoPlayerController? _videoController;

  late XFile file;
  late bool isVideo;
  final int _maxCaptionLength = 2200;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();

    // Extract arguments safely
    final args = Get.arguments as Map<String, dynamic>;
    file = args['file'] as XFile;
    isVideo = args['isVideo'] as bool? ?? false;

    if (isVideo) {
      _initVideoPreview();
    }
  }

  void _initVideoPreview() {
    _videoController = VideoPlayerController.file(File(file.path))
      ..initialize().then((_) {
        if (mounted) setState(() {});
      })
      ..setLooping(true)
      ..setVolume(0)
      ..play();
  }

  @override
  void dispose() {
    _descController.dispose();
    _videoController?.pause(); // Explicitly pause before dispose
    _videoController?.dispose();
    super.dispose();
  }

  // 1. IMPROVED: The "Spam" Proof Upload Logic
  void _uploadPost() {
    // Immediate Guard: Prevent multiple clicks
    if (postController.isLoading.value) return;

    final String caption = _descController.text.trim();

    // Close keyboard
    FocusScope.of(context).unfocus();

    // Trigger Upload
    postController.uploadMediaPost(
      file: file,
      isVideo: isVideo,
      title: caption,
      description: caption,
      text: caption,
      isPublic: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap outside
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppbar(
          title: 'New Post',
          leadingIcon: BackButton(
            color: Colors.black,
            onPressed: () => Get.back(),
          ),
          actionIcon: _buildShareButton(),
        ),
        body: Column(
          children: [
            // Linear Progress bar at the top if uploading
            Obx(() => postController.isLoading.value
                ? const LinearProgressIndicator(minHeight: 2, color: Colors.blue)
                : const Divider(height: 1, thickness: 0.5)),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMediaPreview(),
                        const SizedBox(width: 16),
                        Expanded(child: _buildCaptionField()),
                      ],
                    ),
                    const Divider(height: 40),
                    // You can add "Location", "Tag People", etc. here later
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaPreview() {
    return Container(
      width: 80,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: isVideo
            ? (_videoController?.value.isInitialized ?? false
            ? AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        )
            : const Center(child: CircularProgressIndicator(strokeWidth: 2)))
            : Image.file(File(file.path), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: _descController,
          maxLines: 8,
          minLines: 1,
          maxLength: _maxCaptionLength,
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Write a caption...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            counterText: "", // Hide default counter to use custom one
          ),
        ),
        Text(
          "${_descController.text.length}/$_maxCaptionLength",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildShareButton() {
    return Obx(() {
      bool isLoading = postController.isLoading.value;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: TextButton(
          onPressed: isLoading ? null : _uploadPost,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            disabledForegroundColor: Colors.grey,
          ),
          child: isLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text(
            'Share',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      );
    });
  }
}