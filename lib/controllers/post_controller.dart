import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/app_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/controllers/wallet_controller.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/models/post_model.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:camera/camera.dart' hide ImageFormat;
import 'package:video_thumbnail/video_thumbnail.dart';
import '../data/api/api_checker.dart';
import '../data/repo/post_repo.dart';
import 'dart:io';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import '../data/services/upload_services.dart';
import '../models/comment_model.dart';
import '../models/gift_model.dart';
import '../routes/routes.dart';
import '../widgets/comment_bottom_sheet.dart';
import '../widgets/gift_bottom_modal.dart';

class PostController extends GetxController {
  final PostRepo postRepo;

  PostController({required this.postRepo});

  var posts = <PostModel>[].obs;
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  RxList<CommentModel> comments = <CommentModel>[].obs;
  RxBool isLoading = false.obs;
  UserController userController = Get.find<UserController>();
  List<PostModel> _bookmarkList = [];
  List<PostModel> get bookmarkList => _bookmarkList;
  // Map Index -> VideoController
  final Map<int, VideoPlayerController> videoControllers = {};

  // Set of indexes that are initialized and ready to play
  var initializedIndexes = <int>{}.obs;
  bool isHandlingDeepLink = false;
  int _currentIndex = 0;

  final PageController reelsPageController = PageController();

  @override
  void onClose() {
    reelsPageController.dispose();
    _disposeAll();
    super.onClose();
  }




  void playVideo(int index) {
    _playAtIndex(index);
  }

  void disposeAllControllers() {
    _disposeAll();
  }


  Future<void> deleteUserPost(String postId, String type) async {
    loader.showLoader();

    final PostRepo postRepo = Get.find<PostRepo>();

    try {
      // 2. Call API
      final response = await postRepo.deletePost(postId);
      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
          update(); // Rebuild the grid
          CustomSnackBar.success(message: "Post deleted successfully");
          loader.hideLoader();

        }
       else {
        ApiChecker.checkApi(response);
      }
    } catch (e) {
      loader.hideLoader();
      print("Delete error: $e");
      CustomSnackBar.failure(message: "Failed to delete post");
    }
  }

  Future<void> handleDeepLink(String videoId) async {
    print("🔗 Deep Link Detected for Video ID: $videoId");

    // 1. Lock feed & Pause
    isHandlingDeepLink = true;
    pauseAll();
    loader.showLoader();

    try {
      final response = await postRepo.getPostById(videoId);

      if (response.statusCode == 200) {
        // Parse Deep Link Post
        final dynamic responseData = response.body['data'];
        PostModel? deepLinkPost;

        if (responseData is List && responseData.isNotEmpty) {
          deepLinkPost = PostModel.fromJson(responseData[0]);
        } else if (responseData is Map<String, dynamic>) {
          deepLinkPost = PostModel.fromJson(responseData);
        }

        if (deepLinkPost != null && deepLinkPost.type == 'video') {

          // 2. Prepare the Feed
          // If we already have posts loaded, we can reuse them to save time
          List<PostModel> currentFeed = [];
          if (posts.isNotEmpty) {
            currentFeed = List.from(posts);
          } else {
            // Fetch background feed if empty
            try {
              final recResponse = await postRepo.getRecommendedPosts(contentType: "video");
              if (recResponse.statusCode == 200) {
                final List data = recResponse.body['data'];
                currentFeed = data.map((e) => PostModel.fromJson(e)).toList();
              }
            } catch (e) {
              print("Background feed fetch failed: $e");
            }
          }

          // 3. Merge: [DeepLink, ...Rest]
          // Remove deep link post from existing feed to avoid duplicates
          currentFeed.removeWhere((p) => p.id == deepLinkPost!.id);

          // Assign merged list
          posts.assignAll([deepLinkPost, ...currentFeed]);

          // 4. Reset Navigation
          AppController appController = Get.find<AppController>();
          if (Get.currentRoute != AppRoutes.homeScreen) {
            Get.offAllNamed(AppRoutes.homeScreen);
          }
          if (appController.currentAppPage.value != 0) {
            appController.changeCurrentAppPage(0);
          }

          // 5. Force UI Rebuild
          update();

          // 6. HARD RESET PLAYERS (Fixes Lag/Stuck Frame)
          // We dispose everything completely to ensure a clean slate
          await _disposeAllControllersSafe();

          // 7. Wait for PageView to mount
          await Future.delayed(const Duration(milliseconds: 500));

          if (reelsPageController.hasClients) {
            reelsPageController.jumpToPage(0);
          }

          // 8. Initialize & Play Index 0
          // Use caching logic specifically for the first video
          await _initController(0);
          videoControllers[0]?.play();

          // 9. Preload next
          if (posts.length > 1) _preloadNext(1);

        } else {
          CustomSnackBar.failure(message: "Link content is not a video.");
          Get.offAllNamed(AppRoutes.homeScreen);
        }
      } else {
        CustomSnackBar.failure(message: "Content not found");
        Get.offAllNamed(AppRoutes.homeScreen);
      }
    } catch (e) {
      print("Deep link error: $e");
      Get.offAllNamed(AppRoutes.homeScreen);
    } finally {
      loader.hideLoader();
      // Unlock almost immediately so pagination works
      isHandlingDeepLink = false;
    }
  }

  // Helper for safe disposal
  Future<void> _disposeAllControllersSafe() async {
    for (var controller in videoControllers.values) {
      await controller.pause();
      await controller.dispose();
    }
    videoControllers.clear();
    initializedIndexes.clear();
  }

  Future<void> getBookmarks() async {
    loader.showLoader();
    update();

    Response response = await postRepo.getBookmarkedPosts();

    if (response.statusCode == 200) {
      List<dynamic> rawList = response.body['data'];
      // Parse using PostModel since the structure matches a post
      _bookmarkList = rawList.map((e) => PostModel.fromJson(e)).toList();
    } else {
      ApiChecker.checkApi(response);
    }

    loader.hideLoader();
    update();
  }

  bool isPostBookmarked(String postId) {
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    return post?.isBookmarked ?? false;
  }

  void _updatePostBookmarks(String postId, bool isBookmarking) {
    final postIndex = posts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      final post = posts[postIndex];

      // We create a new copy of the post with the updated bookmark status
      posts[postIndex] = PostModel(
        id: post.id,
        type: post.type,
        text: post.text,
        author: post.author,
        video: post.video,
        image: post.image,
        likes: post.likes,
        comments: post.comments,
        isLiked: post.isLiked,
        isBookmarked: isBookmarking, // <--- Update the flag
      );
    }
  }

  Future<void> toggleBookmark(String postId) async {
    // 1. Get current state
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    if (post == null) return;

    final currentlyBookmarked = post.isBookmarked;
    final shouldBeBookmarked = !currentlyBookmarked;

    // 2. OPTIMISTIC UI UPDATE (Instant feedback)
    _updatePostBookmarks(postId, shouldBeBookmarked);

    // 3. Call API
    final apiCall = currentlyBookmarked
        ? postRepo.unBookmarkPost(postId)
        : postRepo.bookmarkPost(postId);

    try {
      final response = await apiCall;

      if (response.statusCode != 200) {
        // 4. Revert on failure
        print("Bookmark op failed. Status: ${response.statusCode}");
        _updatePostBookmarks(postId, currentlyBookmarked);
        CustomSnackBar.failure(message: "Failed to update bookmark");
      }
    } catch (e) {
      // 5. Revert on network error
      print("Network error during bookmark: $e");
      _updatePostBookmarks(postId, currentlyBookmarked);
      CustomSnackBar.failure(message: "Connection error");
    }
  }

  Future<void> uploadMediaPost({
    required XFile file,
    required bool isVideo,
    required String title,
    required String description,
    required String text,
    required bool isPublic,
  }) async {
    final uploadService = Get.find<UploadService>();

    // Prevent starting a second upload while one is in progress
    if (uploadService.isUploading) {
      CustomSnackBar.failure(message: 'An upload is already in progress.');
      return;
    }

    // ── 1. Generate thumbnail (video only) ───────────────────────────────────
    String? thumbnailPath;
    if (isVideo) {
      try {
        thumbnailPath = await VideoThumbnail.thumbnailFile(
          video: file.path,
          imageFormat: ImageFormat.JPEG,
          maxWidth: 120,
          quality: 60,
        );
      } catch (e) {
        debugPrint('Thumbnail generation failed (non-fatal): $e');
        // Continue without thumbnail — pill will show a camera icon instead
      }
    }

    // ── 2. Navigate away immediately so user can browse ──────────────────────
    // Close the PostDetailsScreen and return to the home feed
    Get.offAllNamed(AppRoutes.homeScreen);
    AppController appController = Get.find<AppController>();
    appController.changeCurrentAppPage(0);

    // ── 3. Start upload in background ────────────────────────────────────────
    // We intentionally do NOT await this — fire and forget.
    // UploadService's reactive state drives the pill widget.
    _runUploadInBackground(
      file: file,
      isVideo: isVideo,
      title: title,
      description: description,
      text: text,
      isPublic: isPublic,
      thumbnailPath: thumbnailPath,
    );
  }

  Future<void> _runUploadInBackground({
    required XFile file,
    required bool isVideo,
    required String title,
    required String description,
    required String text,
    required bool isPublic,
    String? thumbnailPath,
  }) async {
    try {
      final response = isVideo
          ? await postRepo.uploadVideoPost(
        videoFile: file,
        title: title,
        description: description,
        text: text,
        isPublic: isPublic,
        thumbnailPath: thumbnailPath,
      )
          : await postRepo.uploadImagePost(
        imageFile: file,
        title: title,
        description: description,
        text: text,
        isPublic: isPublic,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Refresh the feed so the new post appears
        await loadRecommendedPosts(isVideo ? 'video' : 'image');
      }
      // UploadService already set success/failure state — pill handles UI
    } catch (e) {
      debugPrint('Background upload error: $e');
      // UploadService already set failure state — pill shows the error strip
    }
  }
 /* Future<void> uploadMediaPost({
    required XFile file,
    required bool isVideo,
    required String title,
    required String description,
    required String text, // Use text field for main text content
    required bool isPublic,
  }) async {
    if (isLoading.value) return; // Prevent double-tap upload

    // Simple validation (can be more complex)

    isLoading.value = true;

    try {
      final response = isVideo
          ? await postRepo.uploadVideoPost(
        videoFile: file,
        title: title,
        description: description,
        text: text,
        isPublic: isPublic,
      )
          : await postRepo.uploadImagePost(
        imageFile: file,
        title: title,
        description: description,
        text: text,
        isPublic: isPublic,
      );

      if (response.statusCode == 201) {
        // Post successful!
        CustomSnackBar.success(message: 'Post uploaded successfully!');

        // Navigate back to the main feed/home screen
        Get.offAllNamed(AppRoutes.homeScreen);
        AppController appController = Get.find<AppController>();
        appController.changeCurrentAppPage(0);

        ;


      } else {
        // Handle upload failure error
        String message = response.body?['message'] ?? 'Upload failed. Server error.';
        // CustomSnackBar.failure(message: message);
        print('Upload Failed: $message');
      }

    } catch (e) {
      // Handle network or exception error
      // CustomSnackBar.failure(message: 'Network error during upload.');
      print('Upload Exception: $e');
    } finally {
      isLoading.value = false;
    }
  }*/

  Future<void> submitComment(String postId, String content) async {
    if (content.trim().isEmpty) return;

    final currentUser = userController.user.value;
    if (currentUser == null || currentUser.id.isEmpty) {
      return;
    }

    final commentUser = CommentUserModel(
      id: currentUser.id,
      name: currentUser.name,
      username: currentUser.username,
      profilePicture: currentUser.profilePicture,
    );

    final tempComment = CommentModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      postId: postId,
      content: content.trim(),
      createdAt: DateTime.now(),
      likes: [],
      replies: [],
      user: commentUser,
    );

    comments.insert(0, tempComment);

    try {
      final response = await postRepo.postNewComment(
        postId: postId,
        content: content.trim(),
      );

      if (response.statusCode == 200) {
        // 3. Server Success: Replace the temporary comment with the final server-provided data
        final serverCommentData = response.body['data'];

        // 💡 NEW LOGIC: Use the server's ID and timestamp, but keep the local user object

        // Create a final CommentModel, using the local user data (commentUser)
        // and merging the new server-provided ID and timestamps.
        final finalComment = CommentModel(
          id: serverCommentData['_id'] ?? tempComment.id,
          // Use server ID
          postId: serverCommentData['post'] ?? postId,
          // CRITICAL: Reuse the rich user data object we created locally
          user: tempComment.user,
          content: serverCommentData['content'] ?? tempComment.content,
          likes: serverCommentData['likes'] ?? [],
          replies: serverCommentData['replies'] ?? [],
          createdAt:
              DateTime.tryParse(serverCommentData['createdAt']) ??
              tempComment.createdAt,
        );

        // Find the temporary comment index (using its temporary ID)
        final tempIndex = comments.indexWhere((c) => c.id == tempComment.id);

        if (tempIndex != -1) {
          // Replace the temporary model with the final, persistent model
          comments[tempIndex] = finalComment;
        }

        _incrementPostCommentCount(postId);
      } else {
        print("Comment post failed. Status: ${response.statusCode}");

        comments.removeWhere((c) => c.id == tempComment.id);
      }
    } catch (e) {
      print('🔥 Exception during comment submission: $e');
      comments.removeWhere((c) => c.id == tempComment.id);
    }
  }

  void _incrementPostCommentCount(String postId) {
    final postIndex = posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = posts[postIndex];

      posts[postIndex] = PostModel(
        id: post.id,
        type: post.type,
        text: post.text,
        author: post.author,
        video: post.video,
        image: post.image,
        likes: post.likes,

        comments: [
          ...post.comments,
          {'id': 'temp'},
        ],
        isLiked: post.isLiked,
      );
    }
  }

  void showCommentsForPost(String postId) async {
    pauseAll();

    await fetchComments(postId);

    Get.bottomSheet(
      CommentsBottomSheet(postId: postId),
      isScrollControlled: true, // Allows the sheet to take up more screen space
      backgroundColor: Colors.transparent, // Required for rounded corners
      barrierColor: Colors.black.withOpacity(0.7),
    );
  }

  Future<void> fetchComments(String postId) async {
    if (isLoading.value) return;

    isLoading.value = true;
    comments.clear();

    try {
      final response = await postRepo.getPostComments(postId);

      if (response.statusCode == 200 && response.body != null) {
        final List<dynamic> commentData = response.body['data'] ?? [];

        // Map the JSON list to CommentModel list
        final List<CommentModel> fetchedComments =
            commentData.map((json) {
              return CommentModel.fromJson(json as Map<String, dynamic>);
            }).toList();

        comments.assignAll(fetchedComments);
        print('✅ Fetched ${comments.length} comments for post $postId');
      } else {
        // Handle API error (e.g., 400 Invalid Post ID)
        print('Error fetching comments: ${response.statusCode}');
        // Optionally show a CustomSnackBar error
      }
    } catch (e) {
      print('🔥 Exception during comment fetch: $e');
      // Optionally show a CustomSnackBar error
    } finally {
      isLoading.value = false;
    }
  }

  bool isPostLiked(String postId) {
    if (_currentUserId.isEmpty) return false;
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    return post?.likes.contains(_currentUserId) ?? false;
  }

  void _updatePostLikes(String postId, bool isLiking) {
    final currentUserId = _currentUserId; // Make sure this getter works!
    if (currentUserId.isEmpty) return;

    final postIndex = posts.indexWhere((p) => p.id == postId);

    if (postIndex != -1) {
      final post = posts[postIndex];
      final newLikes = List<dynamic>.from(post.likes);

      if (isLiking) {
        if (!newLikes.contains(currentUserId)) {
          newLikes.add(currentUserId);
        }
      } else {
        newLikes.remove(currentUserId);
      }

      // 💡 CRITICAL CHANGE: Update BOTH likes list AND isLiked flag
      posts[postIndex] = PostModel(
        id: post.id,
        type: post.type,
        text: post.text,
        author: post.author,
        video: post.video,
        image: post.image,
        likes: newLikes,
        comments: post.comments,
        isLiked: isLiking, // <--- UPDATE THE FLAG HERE
      );
    }
  }

  Future<void> toggleLike(String postId) async {
    // Check the current state from the model (relying on server/optimistic flag)
    final post = posts.firstWhereOrNull((p) => p.id == postId);
    final currentlyLiked = post?.isLiked ?? false;

    // The state we want to achieve
    final shouldBeLiked = !currentlyLiked;

    // 1. OPTIMISTIC UI UPDATE
    _updatePostLikes(postId, shouldBeLiked);

    // 2. Determine which API call to make
    final apiCall =
        currentlyLiked
            ? postRepo.unlikePost(postId)
            : postRepo.likePost(postId);

    try {
      final response = await apiCall;

      if (response.statusCode != 200) {
        // 3. Revert Optimistic UI on failure
        print("Like/Unlike failed. Status: ${response.statusCode}");
        // Revert the state
        _updatePostLikes(postId, currentlyLiked);
      }
      // If successful, the UI is already updated optimistically.
      // NOTE: You could optionally parse the response body's new 'likes' list
      // and 'isLiked' flag and update the model again here to ensure
      // perfect server synchronization, but the optimistic update is usually enough.
    } catch (e) {
      // 4. Handle connection or server errors
      print("Network error during like/unlike: $e");
      _updatePostLikes(postId, currentlyLiked); // Revert the UI state
    }
  }

  String get _currentUserId {
    try {
      // Assuming your UserController holds the logged-in user's ID
      final userController = Get.find<UserController>();
      return userController.user.value?.id ??
          ''; // Adjust based on your user model
    } catch (e) {
      print(
        "Error: UserController not found or user ID missing. Cannot perform optimistic like.",
      );
      // Fallback or handle this setup error
      return '';
    }
  }

  Future<void> loadRecommendedPosts(String type) async {

    if (isHandlingDeepLink) {
      print("🚫 Skipping loadRecommendedPosts (Deep Link in progress)");
      return;
    }


    loader.showLoader();
    _disposeAll();
    posts.clear();

    try {
      final response = await postRepo.getRecommendedPosts(contentType: type);
      // Assuming response.body['data'] is the list from your JSON
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List data = response.body['data'];
        posts.value = data.map((e) => PostModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      loader.hideLoader();
    }

    if (posts.isNotEmpty && type == "video") {
      // 1. Start caching the first video immediately
      await _cacheVideoFile(0);
      // 2. Play it
      onPageChanged(0);
      // 3. Pre-load the next ones in background
      _preloadNext(1);
    }
  }

  Future<File?> _cacheVideoFile(int index) async {
    if (index >= posts.length || posts[index].type != 'video') return null;

    final rawUrl = posts[index].video?.url;
    final url = MediaUrlHelper.resolve(rawUrl);

    if (url.isEmpty) return null;

    try {
      debugPrint('🎥 Cache video [$index]');
      debugPrint('   rawUrl: $rawUrl');
      debugPrint('   resolvedUrl: $url');

      return await DefaultCacheManager().getSingleFile(url);
    } catch (e) {
      debugPrint("Cache error $index: $e");
      return null;
    }
  }

  Future<void> _initController(int index) async {
    if (index >= posts.length || posts[index].type != 'video') {
      debugPrint('Controller init skipped: Invalid index or not a video post.');
      return;
    }

    if (videoControllers.containsKey(index)) return;

    final rawUrl = posts[index].video?.url;
    final resolvedUrl = MediaUrlHelper.resolve(rawUrl);

    if (resolvedUrl.isEmpty) {
      debugPrint('❌ Empty resolved video URL at index $index');
      return;
    }

    File? file = await _cacheVideoFile(index);

    late VideoPlayerController controller;

    if (file != null) {
      debugPrint('📁 Using cached file for index $index: ${file.path}');
      controller = VideoPlayerController.file(file);
    } else {
      debugPrint('🌐 Using network URL for index $index: $resolvedUrl');
      controller = VideoPlayerController.networkUrl(Uri.parse(resolvedUrl));
    }

    videoControllers[index] = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);

      initializedIndexes.add(index);

      controller.addListener(() {
        update(['overlay_$index', 'video_item_$index']);
      });

      update(['video_item_$index']);
    } catch (e) {
      debugPrint("Error initializing video $index: $e");
      videoControllers[index]?.dispose();
      videoControllers.remove(index);
      initializedIndexes.remove(index);
      update(['video_item_$index']);
    }
  }

  // --- Playback Logic ---

  void onPageChanged(int index) {
    _currentIndex = index;

    // 1. Play Current
    _playAtIndex(index);

    // 2. Preload Next (Buffer ahead)
    if (index + 1 < posts.length) {
      _preloadNext(index + 1);
      // Init controller but pause it
      _initController(
        index + 1,
      ).then((_) => videoControllers[index + 1]?.pause());
    }

    // 3. Keep Previous (Paused, for quick back nav)
    if (index - 1 >= 0) {
      videoControllers[index - 1]?.pause();
    }

    // 4. Dispose Distant (Memory Management)
    videoControllers.keys.toList().forEach((key) {
      if (key < index - 1 || key > index + 1) {
        videoControllers[key]?.dispose();
        videoControllers.remove(key);
        initializedIndexes.remove(key);
      }
    });
  }

  void _preloadNext(int startIndex) {
    // Just trigger download, don't wait
    for (int i = startIndex; i < startIndex + 2; i++) {
      _cacheVideoFile(i);
    }
  }

  void _playAtIndex(int index) async {
    if (!videoControllers.containsKey(index)) {
      await _initController(index);
    }
    videoControllers[index]?.play();
  }

  void togglePlayPause(int index) {
    final c = videoControllers[index];
    if (c != null && c.value.isInitialized) {
      c.value.isPlaying ? c.pause() : c.play();
      update(['overlay_$index']); // Update play icon
    }
  }

  void pauseAll() {
    videoControllers.values.forEach((c) => c.pause());
  }

  void _disposeAll() {
    videoControllers.values.forEach((c) => c.dispose());
    videoControllers.clear();
    initializedIndexes.clear();
  }
}
