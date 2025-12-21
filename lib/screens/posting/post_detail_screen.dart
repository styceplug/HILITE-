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

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}



class _PostDetailsScreenState extends State<PostDetailsScreen> {
  PostController postController = Get.find<PostController>();
  late TextEditingController _titleController;
  late TextEditingController _descController;
  VideoPlayerController? _videoController;
  late XFile file;
  late bool isVideo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    // 1️⃣ ADD LISTENERS: Forces UI rebuild on typing
    _titleController.addListener(() => setState(() {}));
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
        ..play();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Using a slightly off-white background for contrast with the card
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: const CustomAppbar(title: 'Finalize Post', leadingIcon: BackButton()),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(Dimensions.width20),
          child: Column(
            children: [
              // The Main Content Card
              Card(
                elevation: 2,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radius20),
                ),
                child: Padding(
                  padding: EdgeInsets.all(Dimensions.width15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 3️⃣ MEDIA PREVIEW SECTION
                      _buildMediaPreview(),

                      SizedBox(height: Dimensions.height20),

                      // 4️⃣ TITLE INPUT SECTION
                      _buildInputLabel('Post Title'),
                      SizedBox(height: Dimensions.height10 / 2),
                      CustomTextField(
                        controller: _titleController,
                        hintText: 'Give your post a catchy headline...',
                      ),

                      SizedBox(height: Dimensions.height20),

                      // 5️⃣ DESCRIPTION INPUT SECTION
                      _buildInputLabel('Caption'),
                      SizedBox(height: Dimensions.height10 / 2),
                      CustomTextField(
                        controller: _descController,
                        maxLines: 4,
                        hintText: 'Write a caption, add hashtags...',
                      ),
                      SizedBox(height: Dimensions.height10),
                    ],
                  ),
                ),
              ),

              SizedBox(height: Dimensions.height30),

              // 6️⃣ UPLOAD BUTTON AREA
              Obx(() {
                bool isFormInvalid = _titleController.text.trim().isEmpty ||
                    _descController.text.trim().isEmpty;

                return CustomButton(
                  text: 'Share Post',
                  isLoading: postController.isLoading.value,
                  onPressed: (postController.isLoading.value || isFormInvalid)
                      ? null
                      : () {
                    FocusScope.of(context).unfocus();
                    postController.uploadMediaPost(
                      file: file,
                      isVideo: isVideo,
                      title: _titleController.text.trim(),
                      description: _descController.text.trim(),
                      text: _descController.text.trim(),
                      isPublic: true,
                    );
                  },
                  isDisabled: isFormInvalid,
                );
              }),
              SizedBox(height: Dimensions.height20),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for input labels
  Widget _buildInputLabel(String label) {
    return Padding(
      padding: EdgeInsets.only(left: Dimensions.width10 / 2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: Dimensions.font16,
          fontWeight: FontWeight.w600,
          color: Colors.grey[800],
        ),
      ),
    );
  }

  // Refactored Media Preview Widget
  Widget _buildMediaPreview() {
    // Define a fixed height for the preview container to look uniform
    final double previewHeight = Dimensions.height10 * 25; // Approx 250px depending on your Dimensions setup

    return Container(
      height: previewHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Dimensions.radius15),
        child: isVideo
            ? (_videoController?.value.isInitialized ?? false)
            ? FittedBox(
          // Use FittedBox to cover the container area
          fit: BoxFit.cover,
          child: SizedBox(
            width: _videoController!.value.size.width,
            height: _videoController!.value.size.height,
            child: VideoPlayer(_videoController!),
          ),
        )
            : const Center(child: CircularProgressIndicator(color: Colors.white))
            : Image.file(
          File(file.path),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.white54,
                size: Dimensions.iconSize30 * 1.5,
              ),
            );
          },
        ),
      ),
    );
  }
}