import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  late TextEditingController _titleController;
  late TextEditingController _descController;
  VideoPlayerController? _videoController;
  bool _isUploading = false;
  late XFile file;
  late bool isVideo;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descController = TextEditingController();

    // Retrieve passed arguments
    final args = Get.arguments as Map<String, dynamic>;
    file = args['file'] as XFile;
    isVideo = args['isVideo'] as bool? ?? false;

    // Initialize video controller if needed
    if (isVideo) {
      _videoController =
          VideoPlayerController.file(File(file.path))
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

  Future<void> _uploadPost() async {
    setState(() => _isUploading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Post uploaded successfully!')),
    );
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(title: 'Post Details', leadingIcon: BackButton()),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height20,
        ),
        child: Column(
          children: [
            isVideo
                ? (_videoController?.value.isInitialized ?? false)
                    ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                    : SizedBox(
                      height: Dimensions.height20 * 10,
                      child: Center(child: AppLoadingOverlay()),
                    )
                : Image.file(
                  File(file.path),
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: Dimensions.height20 * 10,
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(
                          Dimensions.radius20,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.error,
                          color: Colors.red,
                          size: Dimensions.iconSize30,
                        ),
                      ),
                    );
                  },
                ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              controller: _titleController,
              hintText: 'Post Title',
            ),
            SizedBox(height: Dimensions.height20),
            CustomTextField(
              controller: _descController,
              maxLines: 5,
              hintText: 'Post Description',
            ),
            SizedBox(height: Dimensions.height20),
            CustomButton(
              text: 'Upload Post',
              onPressed: () {
                _isUploading ? null : _uploadPost;
              },
              isLoading: _isUploading,
              isDisabled:
                  _titleController.text.isEmpty || _descController.text.isEmpty,
            ),
          ],
        ),
      ),
    );
  }
}
