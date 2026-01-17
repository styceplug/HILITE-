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
  PostController postController = Get.find<PostController>();
  late TextEditingController _descController;
  VideoPlayerController? _videoController;
  late XFile file;
  late bool isVideo;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
    _descController.addListener(() => setState(() {}));

    final args = Get.arguments as Map<String, dynamic>;
    file = args['file'] as XFile;
    isVideo = args['isVideo'] as bool? ?? false;

    if (isVideo) {
      _videoController = VideoPlayerController.file(File(file.path))
        ..initialize().then((_) {
          if (mounted) setState(() {});
        })
        ..setLooping(true)
        ..setVolume(0) // Mute preview by default so it's not annoying
        ..play();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      appBar: CustomAppbar(
        title: 'New Post',
        leadingIcon: const BackButton(color: Colors.black),
        actionIcon: _buildShareTextButton(), // specialized "Post" button in app bar
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // 1️⃣ THE COMPOSE ROW (Thumbnail + Caption)
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildThumbnail(),
                        SizedBox(width: Dimensions.width15),
                        Expanded(child: _buildCaptionField()),
                      ],
                    ),
                  ),


                ],
              ),
            ),
          ),
        ],
      ),

    );
  }

  // --- WIDGETS ---

  Widget _buildThumbnail() {
    return Container(
      height: 100, // Fixed height
      width: 80,   // Fixed width (Vertical aspect ratio)
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: isVideo
            ? (_videoController?.value.isInitialized ?? false)
            ? FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        )
            : const Center(child: CircularProgressIndicator(strokeWidth: 2))
            : Image.file(
          File(file.path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return TextField(
      controller: _descController,
      maxLines: 5, // Allows multi-line typing
      minLines: 1,
      style: TextStyle(
        fontSize: Dimensions.font16,
        color: Colors.black87,
      ),
      decoration: InputDecoration(
        hintText: 'Write a caption...',
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: Dimensions.font16,
        ),
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildShareTextButton() {
    return Obx(() {
      // 1. Check loading state
      bool isLoading = postController.isLoading.value;

      // 2. We remove the text check.
      // As long as we have media (which we do), the post is valid.
      bool isInvalid = false;

      if (isLoading) {
        return Padding(
          padding: EdgeInsets.only(right: Dimensions.width20),
          child: const Center(
            child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2)
            ),
          ),
        );
      }

      return CustomButton(
        onPressed: _uploadPost,
        text:
          'Share',
        backgroundColor: AppColors.white,
        isDisabled: _descController.text.isEmpty,
      );
    });
  }

  void _uploadPost() {
    print("🔘 Share button tapped!");

    FocusScope.of(context).unfocus();

    final String caption = _descController.text.trim();

    postController.uploadMediaPost(
      file: file,
      isVideo: isVideo,
      title: caption,
      description: caption,
      text: caption,
      isPublic: true,
    );
  }
}