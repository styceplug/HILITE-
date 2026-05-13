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

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart';

class PostDetailsScreen extends StatefulWidget {
  const PostDetailsScreen({super.key});

  @override
  State<PostDetailsScreen> createState() => _PostDetailsScreenState();
}

class _PostDetailsScreenState extends State<PostDetailsScreen> {
  final PostController postController = Get.find<PostController>();
  late TextEditingController _descController;
  late TextEditingController _tagController;
  VideoPlayerController? _videoController;

  late XFile file;
  late bool isVideo;
  final int _maxCaptionLength = 2200;

  // --- TAGGING STATE ---
  List<String> selectedTags = [];
  final List<String> suggestedTags = ['Speed', 'Dribbling', 'Finishing', 'Goal', 'Highlights', 'ScoutMe'];

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController();
    _tagController = TextEditingController();

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
    _tagController.dispose();
    _videoController?.pause();
    _videoController?.dispose();
    super.dispose();
  }

  // --- TAG LOGIC ---
  void _addTag(String tag) {
    String cleanTag = tag.trim().replaceAll('#', '');
    if (cleanTag.isNotEmpty && !selectedTags.contains(cleanTag)) {
      setState(() {
        selectedTags.add(cleanTag);
        _tagController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      selectedTags.remove(tag);
    });
  }

  void _uploadPost() {
    if (postController.isLoading.value) return;

    final String caption = _descController.text.trim();

    // Create a local copy of the tags to guarantee everything is captured
    List<String> finalTags = List.from(selectedTags);

    // If they typed a tag but forgot to press space/enter before clicking post, catch it!
    String pendingTag = _tagController.text.trim().replaceAll('#', '');
    if (pendingTag.isNotEmpty && !finalTags.contains(pendingTag)) {
      finalTags.add(pendingTag);
    }

    FocusScope.of(context).unfocus();

    // --- DEBUG PRINT ---
    debugPrint("📱 [UI LAYER] UPLOADING WITH TAGS: $finalTags");

    postController.uploadMediaPost(
      file: file,
      isVideo: isVideo,
      title: caption,
      description: caption,
      text: caption,
      isPublic: true,
      tags: finalTags, // <-- Pass the guaranteed list
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF030A1B),
        appBar: CustomAppbar(
          backgroundColor: const Color(0xFF030A1B),
          title: 'Upload new post',
          leadingIcon: BackButton(
            color: Colors.white,
            onPressed: () => Get.back(),
          ),
        ),
        body: Column(
          children: [
            Obx(() => postController.isLoading.value
                ? const LinearProgressIndicator(minHeight: 2, color: Colors.blueAccent)
                : Divider(height: 1, thickness: 0.5, color: Colors.white.withOpacity(0.1))),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMediaPreview(),
                    const SizedBox(height: 30),
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
    String formatDuration(Duration duration) {
      String twoDigits(int n) => n.toString().padLeft(2, "0");
      String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
      String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
      if (duration.inHours > 0) {
        return "${duration.inHours}:$twoDigitMinutes:$twoDigitSeconds";
      }
      return "$twoDigitMinutes:$twoDigitSeconds";
    }

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
        child: isVideo
            ? (_videoController?.value.isInitialized ?? false
            ? Stack(
          fit: StackFit.expand,
          children: [
            FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: _videoController!.value.size.width,
                height: _videoController!.value.size.height,
                child: VideoPlayer(_videoController!),
              ),
            ),
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _videoController!.value.isPlaying
                        ? _videoController!.pause()
                        : _videoController!.play();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), shape: BoxShape.circle),
                  child: Icon(
                    _videoController!.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                child: Text(
                  formatDuration(_videoController!.value.duration),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        )
            : const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blueAccent)))
            : Image.file(
          File(file.path),
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildCaptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- CAPTION INPUT ---
        CustomTextField( // Assuming your CustomTextField takes styling
          controller: _descController,
          hintText: 'Write a caption...',
          maxLines: 3,
          onChanged: (val) => setState(() {}),
        ),
        const SizedBox(height: 5),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "${_descController.text.length}/$_maxCaptionLength",
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12),
          ),
        ),
        const SizedBox(height: 20),

        // --- TAG INPUT ---
        const Text("Tags", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),

        TextField(
          controller: _tagController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Add a tag and press Space...',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            prefixIcon: Icon(Icons.tag, color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onChanged: (val) {
            // Automatically add tag if user presses space or comma
            if (val.endsWith(' ') || val.endsWith(',')) {
              _addTag(val.substring(0, val.length - 1));
            }
          },
          onSubmitted: (val) => _addTag(val),
        ),
        const SizedBox(height: 15),

        // --- SELECTED TAGS WRAP ---
        if (selectedTags.isNotEmpty) ...[
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: selectedTags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('#$tag', style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => _removeTag(tag),
                    child: const Icon(Icons.close, color: Colors.blueAccent, size: 14),
                  )
                ],
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
        ],

        // --- SUGGESTED TAGS ---
        Text("Suggested", style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: suggestedTags.map((tag) {
              bool isSelected = selectedTags.contains(tag);
              return GestureDetector(
                onTap: () {
                  isSelected ? _removeTag(tag) : _addTag(tag);
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? Colors.blueAccent : Colors.white.withOpacity(0.1)),
                  ),
                  child: Text(
                    '#$tag',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 40),
        _buildShareButton()
      ],
    );
  }

  Widget _buildShareButton() {
    return Obx(() {
      bool isLoading = postController.isLoading.value;
      return SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          onPressed: isLoading ? null : _uploadPost,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: isLoading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Share Post', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
      );
    });
  }
}
