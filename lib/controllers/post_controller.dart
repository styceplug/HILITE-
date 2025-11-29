
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/models/post_model.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:video_player/video_player.dart';

import '../data/repo/post_repo.dart';

/*
class PostController extends GetxController {
  final PostRepo postRepo;
  PostController({required this.postRepo});

  // Data State
  var posts = <PostModel>[].obs;
  var isLoading = false.obs;

  // Video Management State
  final Map<int, VideoPlayerController> videoControllers = {};

  // We keep track of initialized indexes to update UI smoothly
  var initializedIndexes = <int>{}.obs;

  int _currentIndex = 0;

  @override
  void onClose() {
    _disposeAllVideos();
    super.onClose();
  }

  // -----------------------------
  // Data Loading
  // -----------------------------
  Future<void> loadRecommendedPosts(String type) async {
    isLoading.value = true;
    _disposeAllVideos();
    posts.clear();

    try {
      final response = await postRepo.getRecommendedPosts(contentType: type);
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body['data'] as List;
        posts.value = data.map((e) => PostModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("Error loading posts: $e");
    } finally {
      isLoading.value = false;
    }

    // Initialize the first video immediately if data exists
    if (posts.isNotEmpty && type == "video") {
      onPageChanged(0);
    }
  }

  // -----------------------------
  // Smart Video Lifecycle (The Core Optimization)
  // -----------------------------
  void onPageChanged(int index) {
    _currentIndex = index;

    // 1. Play Current
    _playController(index);

    // 2. Preload Next (Buffer)
    if (index + 1 < posts.length) {
      _initializeController(index + 1).then((_) {
        // Ensure it doesn't play automatically, just buffers
        videoControllers[index + 1]?.pause();
      });
    }

    // 3. Keep Previous (Paused, for quick back nav)
    if (index - 1 >= 0) {
      videoControllers[index - 1]?.pause();
    }

    // 4. Garbage Collection (Dispose videos far away)
    // We only keep [index - 1], [index], [index + 1]
    videoControllers.keys.toList().forEach((key) {
      if (key < index - 1 || key > index + 1) {
        _disposeController(key);
      }
    });
  }

  Future<void> _initializeController(int index) async {
    // If already initialized, just return
    if (videoControllers.containsKey(index)) return;

    final post = posts[index];
    if (post.type != 'video' || post.video?.url == null) return;

    final controller = VideoPlayerController.network(post.video!.url!);
    videoControllers[index] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      initializedIndexes.add(index); // Notify UI
    } catch (e) {
      print("Error init video $index: $e");
      // Clean up if init failed
      videoControllers.remove(index);
    }
  }

  void _playController(int index) async {
    // Ensure initialized
    if (!videoControllers.containsKey(index)) {
      await _initializeController(index);
    }

    final controller = videoControllers[index];
    if (controller != null && controller.value.isInitialized) {
      controller.play();
    }
  }

  void _disposeController(int index) {
    if (videoControllers.containsKey(index)) {
      videoControllers[index]?.dispose();
      videoControllers.remove(index);
      initializedIndexes.remove(index);
    }
  }

  void _disposeAllVideos() {
    videoControllers.forEach((_, controller) => controller.dispose());
    videoControllers.clear();
    initializedIndexes.clear();
  }

  // -----------------------------
  // User Actions
  // -----------------------------
  void togglePlayPause(int index) {
    final controller = videoControllers[index];
    if (controller != null && controller.value.isInitialized) {
      controller.value.isPlaying ? controller.pause() : controller.play();
      // Force UI update to show play/pause icon
      update(['video_overlay_$index']);
    }
  }

  void stopAll() {
    videoControllers.values.forEach((element) => element.pause());
  }
}*/

import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PostController extends GetxController {
  final PostRepo postRepo;
  PostController({required this.postRepo});

  var posts = <PostModel>[].obs;
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();


  // Map Index -> VideoController
  final Map<int, VideoPlayerController> videoControllers = {};

  // Set of indexes that are initialized and ready to play
  var initializedIndexes = <int>{}.obs;

  int _currentIndex = 0;

  @override
  void onClose() {
    _disposeAll();
    super.onClose();
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
    final apiCall = currentlyLiked
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
      return userController.user.value?.id ?? ''; // Adjust based on your user model
    } catch (e) {
      print("Error: UserController not found or user ID missing. Cannot perform optimistic like.");
      // Fallback or handle this setup error
      return '';
    }
  }


  Future<void> loadRecommendedPosts(String type) async {
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

  // --- Caching Logic ---

  Future<File?> _cacheVideoFile(int index) async {
    if (index >= posts.length || posts[index].type != 'video') return null;
    final url = posts[index].video?.url;
    if (url == null) return null;

    try {
      // This downloads to disk. If already downloaded, returns file instantly.
      return await DefaultCacheManager().getSingleFile(url);
    } catch (e) {
      print("Cache error $index: $e");
      return null;
    }
  }

  Future<void> _initController(int index) async {

    if (index >= posts.length || posts[index].type != 'video') {
      print('Controller init skipped: Invalid index or not a video post.');
      return;
    }

    if (videoControllers.containsKey(index)) return;

    // Try getting local file first (Speed!)
    File? file = await _cacheVideoFile(index);

    VideoPlayerController controller;
    if (file != null) {
      controller = VideoPlayerController.file(file);
    } else {
      // Fallback to network if cache failed
      controller = VideoPlayerController.network(posts[index].video!.url!);
    }

    videoControllers[index] = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      initializedIndexes.add(index);
      controller.addListener(() {
        update(['overlay_$index']);
      });
      controller.setLooping(true);
      initializedIndexes.add(index); // Update UI
    } catch (e) {
      videoControllers.remove(index);
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
      _initController(index + 1).then((_) => videoControllers[index + 1]?.pause());
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
