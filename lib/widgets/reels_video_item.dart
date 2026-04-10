import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/pulse_loader.dart';
import 'package:hilite/widgets/reel_overlay.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/post_controller.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class ReelsVideoItem extends StatefulWidget {
  final int index;
  final PostModel post;
  final PostController controller;
  final String? tag;

  const ReelsVideoItem({
    Key? key,
    required this.index,
    required this.post,
    required this.controller,
    this.tag,
  }) : super(key: key);

  @override
  State<ReelsVideoItem> createState() => _ReelsVideoItemState();
}

class _ReelsVideoItemState extends State<ReelsVideoItem>
    with TickerProviderStateMixin {
  bool _isSpeedingUp = false;
  bool _isDragging = false;

  late AnimationController _speedAnimController;
  late Animation<double> _speedOpacity;
  late AnimationController _bufferingAnimController;
  late Animation<double> _bufferingOpacity;

  @override
  void initState() {
    super.initState();
    _speedAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _speedOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_speedAnimController);

    _bufferingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _bufferingOpacity = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(_bufferingAnimController);
  }

  @override
  void dispose() {
    _speedAnimController.dispose();
    _bufferingAnimController.dispose();
    super.dispose();
  }

  void _startSpeedUp(TapDownDetails details, VideoPlayerController videoCtrl) {
    final screenWidth = MediaQuery.of(context).size.width;
    // Right side of screen triggers speed up
    if (details.globalPosition.dx > screenWidth * 0.6) {
      videoCtrl.setPlaybackSpeed(2.0);
      setState(() => _isSpeedingUp = true);
      _speedAnimController.forward();
    }
  }

  void _endSpeedUp(VideoPlayerController videoCtrl) {
    if (_isSpeedingUp) {
      videoCtrl.setPlaybackSpeed(1.0);
      setState(() => _isSpeedingUp = false);
      _speedAnimController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostController>(
      id: 'video_item_${widget.index}',
      tag: widget.tag,
      builder: (controller) {
        final videoCtrl = widget.controller.videoControllers[widget.index];
        final isReady = widget.controller.initializedIndexes.contains(
          widget.index,
        );

        return VisibilityDetector(
          key: Key(
            'reel-${widget.tag ?? 'main'}-${widget.post.id}-${widget.index}',
          ),
          onVisibilityChanged: (visibilityInfo) {
            final visibleFraction = visibilityInfo.visibleFraction;

            if (visibleFraction < 0.4) {
              if (videoCtrl != null) {
                _endSpeedUp(videoCtrl);
              }
              unawaited(widget.controller.stopVideoAtIndex(widget.index));
              return;
            }

            if (visibleFraction > 0.9 &&
                widget.controller.currentIndex == widget.index &&
                widget.controller.isPlaybackActive) {
              unawaited(widget.controller.playVideo(widget.index));
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            // Ensures taps are caught
            onTap: () => widget.controller.togglePlayPause(widget.index),
            onTapDown: (details) {
              if (isReady && videoCtrl != null) {
                _startSpeedUp(details, videoCtrl);
              }
            },
            onTapUp: (_) {
              if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
            },
            onTapCancel: () {
              if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
            },
            onLongPressEnd: (_) {
              if (isReady && videoCtrl != null) _endSpeedUp(videoCtrl);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // 1. THUMBNAIL
                _buildThumbnail(),

                // 1. BACKGROUND
                if (isReady &&
                    videoCtrl != null &&
                    videoCtrl.value.isInitialized)
                  Container(
                    color: Colors.black,
                  ) // black bg when video is playing
                else if (widget.post.video?.thumbnailUrl != null)
                  Image.network(
                    widget.post.video!.thumbnailUrl!,
                    fit: BoxFit.cover,
                  ) // thumbnail while loading
                else
                  const PulseLoader(),

                // 2. VIDEO PLAYER
                if (isReady &&
                    videoCtrl != null &&
                    videoCtrl.value.isInitialized)
                  _buildVideoPlayer(videoCtrl),

                // 3. "2X SPEED" OVERLAY
                if (isReady)
                  Positioned(
                    top: 50,
                    right: 0,
                    left: 0,
                    child: FadeTransition(
                      opacity: _speedOpacity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.fast_forward_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "2x Speed",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // 4. PLAY/PAUSE ICON (Animated)
                if (isReady && videoCtrl != null)
                  Center(
                    child: ValueListenableBuilder(
                      valueListenable: videoCtrl,
                      builder: (context, VideoPlayerValue value, child) {
                        if (_isSpeedingUp || _isDragging) {
                          return const SizedBox.shrink();
                        }

                        if (value.isBuffering) {
                          return _buildBufferingIndicator();
                        }

                        if (!value.isPlaying) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.3),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(15),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),

                // 5. INTERACTION OVERLAY
                // (Buttons like "Like", "Comment" inside this widget will still work
                // because they sit on top and consume their own touch events)
                if (!_isDragging)
                  ReelsInteractionOverlay(
                    post: widget.post,
                    controller: widget.controller,
                  ),

                // 6. PROGRESS BAR
                if (isReady && videoCtrl != null)
                  Positioned(
                    bottom:
                        Dimensions.bottomNavIconHeight +
                        Dimensions.height10 * 9,
                    left: 0,
                    right: 0,
                    child: _buildProgressBar(videoCtrl),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThumbnail() {
    final thumb = MediaUrlHelper.resolve(widget.post.video?.thumbnailUrl);

    if (thumb.isEmpty) {
      return Container(color: Colors.black);
    }

    return Stack(
      children: [
        Image.network(
          thumb,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(color: Colors.black);
          },
        ),
        PulseLoader(),
      ],
    );
  }

  Widget _buildVideoPlayer(VideoPlayerController controller) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final videoSize = controller.value.size;

        if (videoSize.isEmpty) {
          return const SizedBox.shrink();
        }

        final videoAspectRatio = videoSize.width / videoSize.height;
        final viewportAspectRatio =
            constraints.maxWidth / constraints.maxHeight;

        late final double width;
        late final double height;

        if (videoAspectRatio > viewportAspectRatio) {
          height = constraints.maxHeight;
          width = height * videoAspectRatio;
        } else {
          width = constraints.maxWidth;
          height = width / videoAspectRatio;
        }

        return Center(
          child: SizedBox(
            width: width,
            height: height,
            child: VideoPlayer(controller),
          ),
        );
      },
    );
  }

  Widget _buildBufferingIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.38),
        shape: BoxShape.circle,
      ),
      child: const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: Colors.white),
      ),
    );
  }

  Widget _buildProgressBar(VideoPlayerController controller) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, VideoPlayerValue value, child) {
        final duration = value.duration.inMilliseconds;
        final position = value.position.inMilliseconds;
        double max = duration.toDouble();
        double current = position.toDouble();

        if (current > max) current = max;
        if (max <= 0) max = 1.0;

        // ✅ FIX: Corrected SliderThemeData error
        return SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 2.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 10.0),
            activeTrackColor: Colors.white,
            inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
            thumbColor: Colors.white,
            overlayColor: Colors.white.withValues(alpha: 0.4),
          ),
          child: FadeTransition(
            opacity:
                value.isBuffering
                    ? _bufferingOpacity
                    : AlwaysStoppedAnimation(1),
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 2.0,
                activeTrackColor: Colors.white,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                thumbColor: Colors.white,
              ),
              child: Slider(
                value: current,
                min: 0.0,
                max: max,
                onChangeStart: (_) {
                  setState(() => _isDragging = true);
                  controller.pause();
                },
                onChangeEnd: (_) {
                  setState(() => _isDragging = false);
                  controller.play();
                },
                onChanged: (val) {
                  controller.seekTo(Duration(milliseconds: val.toInt()));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class ProfileReelsPlayer extends StatefulWidget {
  final List<PostModel> videos;
  final int initialIndex;
  final UserModel? authorProfile;

  const ProfileReelsPlayer({
    Key? key,
    required this.videos,
    required this.initialIndex,
    this.authorProfile, // 2. Add to constructor
  }) : super(key: key);

  @override
  State<ProfileReelsPlayer> createState() => _ProfileReelsPlayerState();
}

class _ProfileReelsPlayerState extends State<ProfileReelsPlayer>
    with WidgetsBindingObserver {
  late PostController _profileController;
  final String _controllerTag = 'profile_reels';

  @override
  void initState() {
    super.initState();
    // 2. Register the observer to listen for app backgrounding
    WidgetsBinding.instance.addObserver(this);

    _profileController = Get.put(
      PostController(postRepo: Get.find()),
      tag: _controllerTag,
    );

    _profileController.posts.assignAll(widget.videos);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_profileController.reelsPageController.hasClients) {
        _profileController.reelsPageController.jumpToPage(widget.initialIndex);
      }
      _profileController.activatePlayback();
      _profileController.onPageChanged(widget.initialIndex);
    });
  }

  @override
  void dispose() {
    // 3. Clean up hardware and observers
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_profileController.deactivatePlayback());
    unawaited(_profileController.disposeAllControllers());
    Get.delete<PostController>(tag: _controllerTag);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      unawaited(_profileController.deactivatePlayback());
    } else if (state == AppLifecycleState.resumed) {
      _resumeCurrentVideo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          VisibilityDetector(
            key: Key(_controllerTag),
            onVisibilityChanged: (visibilityInfo) {
              final visiblePercentage = visibilityInfo.visibleFraction * 100;
              if (visiblePercentage < 1) {
                unawaited(_profileController.deactivatePlayback());
              } else {
                _resumeCurrentVideo();
              }
            },
            child: PageView.builder(
              controller: _profileController.reelsPageController,
              scrollDirection: Axis.vertical,
              itemCount: _profileController.posts.length,
              onPageChanged: (index) => _profileController.onPageChanged(index),
              itemBuilder: (_, index) {
                return ReelsVideoItem(
                  index: index,
                  post: _profileController.posts[index],
                  controller: _profileController,
                  tag: _controllerTag,
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Get.back();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resumeCurrentVideo() {
    final currentIndex =
        _profileController.reelsPageController.hasClients
            ? _profileController.reelsPageController.page?.round() ??
                widget.initialIndex
            : widget.initialIndex;

    _profileController.activatePlayback();
    _profileController.playVideo(currentIndex);
  }
}
