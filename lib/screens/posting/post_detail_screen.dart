import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/post_controller.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_player/video_player.dart';

import '../../utils/colors.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PostController postController = Get.find<PostController>();
  TextEditingController _descController = TextEditingController();
  TextEditingController tagController = TextEditingController();
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
    _videoController =
    VideoPlayerController.file(File(file.path))
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
      onTap:
          () =>
          FocusScope.of(
            context,
          ).unfocus(),
      child: Scaffold(
        appBar: CustomAppbar(
          title: 'Upload new post',
          leadingIcon: BackButton(
            color: Colors.white,
            onPressed: () => Get.back(),
          ),
          // actionIcon: _buildShareButton(),
        ),
        body: Column(
          children: [
            Obx(
                  () =>
              postController.isLoading.value
                  ? const LinearProgressIndicator(
                minHeight: 2,
                color: Colors.blue,
              )
                  : Divider(
                height: 1,
                thickness: 0.5,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildMediaPreview(),
                    SizedBox(height: Dimensions.height50),

                    _buildCaptionField(),
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
      width: Dimensions.screenWidth,
      height: Dimensions.screenHeight / 2.5,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child:
        isVideo
            ? (_videoController?.value.isInitialized ?? false
            ? SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: SizedBox(
              width: _videoController!.value.size.width,
              height: _videoController!.value.size.height,
              child: VideoPlayer(_videoController!),
            ),
          ),
        )
            : const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ))
            : Image.file(
          File(file.path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover, // Updated to match the video behavior
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        CustomTextField(
          controller: _descController,
          hintText: 'Add a caption...',
          maxLines: 1,
          prefixIcon: Iconsax.hashtag,
          onChanged: (val) => setState(() {}),
        ),
        Text(
          "${_descController.text.length}/$_maxCaptionLength",
          style: TextStyle(color: Colors.grey[400], fontSize: 12),
        ),

        SizedBox(height: Dimensions.height10),
        CustomTextField(
          controller: tagController,
          maxLines: 1,
          prefixIcon: Iconsax.tag_right,
          onChanged: (val) => setState(() {}),
          hintText: 'Add Tags',
        ),
        SizedBox(height: Dimensions.height10),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width5,
                vertical: Dimensions.height5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius5),
                color: AppColors.white.withOpacity(0.1),
              ),
              child: Text(
                '#Speed',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width5,
                vertical: Dimensions.height5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius5),
                color: AppColors.white.withOpacity(0.1),
              ),
              child: Text(
                '#Dribbling',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width5,
                vertical: Dimensions.height5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius5),
                color: AppColors.white.withOpacity(0.1),
              ),
              child: Text(
                '#Finishing',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: Dimensions.width5,
                vertical: Dimensions.height5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius5),
                color: AppColors.white.withOpacity(0.1),
              ),
              child: Text(
                '#Goal',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: Dimensions.height30),
        _buildShareButton()

      ],
    );
  }

  Widget _buildShareButton() {
    return Obx(() {
      bool isLoading = postController.isLoading.value;

      return Container(
        width: Dimensions.screenWidth,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: CustomButton(
            onPressed: isLoading ? null : _uploadPost,
            backgroundColor: AppColors.buttonColor,
            isLoading:isLoading,
            text:'Post'
        ),
      );
    });
  }
}
