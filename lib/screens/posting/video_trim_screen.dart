import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/app_loading_overlay.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/snackbars.dart';
// import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';

class VideoTrimScreen extends StatefulWidget {
  final XFile file;

  const VideoTrimScreen({super.key, required this.file});

  @override
  State<VideoTrimScreen> createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  VideoPlayerController? _videoController;
  bool _isLoadingVideo = true;
  bool _isSavingVideo = false;
  String? _loadError;
  static const Duration _maxDuration = Duration(minutes: 1);
  static const _channel = MethodChannel('video_trimmer_native');
  Duration _videoDuration = Duration.zero;
  double _startFraction = 0.0;
  double _endFraction = 1.0;

  Duration get _startTrim => _videoDuration * _startFraction;

  Duration get _endTrim => _videoDuration * _endFraction;

  Duration get _selectedDuration => _endTrim - _startTrim;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    try {
      final controller = VideoPlayerController.file(File(widget.file.path));
      await controller.initialize();
      await controller.setLooping(true);

      if (!mounted) return;
      setState(() {
        _videoController = controller;
        _videoDuration = controller.value.duration;
        _isLoadingVideo = false;
        if (_videoDuration > _maxDuration) {
          _endFraction =
              _maxDuration.inMilliseconds / _videoDuration.inMilliseconds;
        }
      });
    } catch (e) {
      debugPrint('Video load error: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingVideo = false;
        _loadError = 'Could not open this video for editing.';
      });
    }
  }

  Future<void> _continueToPostDetails({bool useOriginal = false}) async {
    if (_isSavingVideo) return;

    if (useOriginal || _loadError != null || _videoController == null) {
      _openPostDetails(widget.file);
      return;
    }

    // No meaningful trim — use original
    if (_startFraction <= 0.01 && _endFraction >= 0.99) {
      _openPostDetails(widget.file);
      return;
    }

    try {
      setState(() => _isSavingVideo = true);
      await _videoController?.pause();

      final outputPath = await _channel.invokeMethod<String>('trimVideo', {
        'inputPath': widget.file.path,
        'startMs': _startTrim.inMilliseconds,
        'durationMs': _selectedDuration.inMilliseconds,
      });

      if (!mounted) return;

      if (outputPath == null || outputPath.isEmpty) {
        setState(() => _isSavingVideo = false);
        CustomSnackBar.failure(message: 'Could not trim this video. Try again.');
        return;
      }

      _openPostDetails(XFile(outputPath));

    } catch (e) {
      debugPrint('Video trim error: $e');
      if (!mounted) return;
      setState(() => _isSavingVideo = false);
      CustomSnackBar.failure(message: 'Could not trim this video.');
    }
  }

  void _openPostDetails(XFile file) {
    Get.offNamed(
      AppRoutes.postDetailScreen,
      arguments: {'file': file, 'isVideo': true},
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isSavingVideo,
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: CustomAppbar(
          title: 'Trim Video',
          backgroundColor: Colors.black,
          titleColor: Colors.white,
          leadingIcon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    Expanded(child: _buildContent(context)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed:
                                _isSavingVideo
                                    ? null
                                    : () => _continueToPostDetails(
                                      useOriginal: true,
                                    ),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: const Text(
                              'Use Original',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: CustomButton(
                            onPressed: () => _continueToPostDetails(),
                            isLoading: _isSavingVideo,
                            backgroundColor: AppColors.primary,
                            text: 'Continue',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isSavingVideo)
              const Positioned.fill(child: AppLoadingOverlay()),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoadingVideo) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_loadError != null || _videoController == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.video_file_outlined,
                color: Colors.white70,
                size: 56,
              ),
              const SizedBox(height: 16),
              Text(
                _loadError ?? 'Could not open this video.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'You can continue with the original file if you do not need to trim it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final controller = _videoController!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adjust the handles to choose the part of the video you want to upload.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),

        // Replace the video preview Expanded widget:
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: FittedBox(
                fit: BoxFit.contain,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Trim controls
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            children: [
              // Custom range slider
              _TrimRangeSlider(
                startFraction: _startFraction,
                endFraction: _endFraction,
                maxFraction:
                    _videoDuration > _maxDuration
                        ? _maxDuration.inMilliseconds /
                            _videoDuration.inMilliseconds
                        : 1.0,
                onChanged: (start, end) {
                  setState(() {
                    _startFraction = start;
                    _endFraction = end;
                  });
                  // Seek to start when trimming
                  final seekTo = _videoDuration * start;
                  controller.seekTo(seekTo);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(label: 'Start', value: _fmt(_startTrim)),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      label: 'Selected',
                      value: _fmt(_selectedDuration),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(label: 'End', value: _fmt(_endTrim)),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Play/pause
        Center(
          child: ValueListenableBuilder<VideoPlayerValue>(
            valueListenable: controller,
            builder: (_, value, __) {
              return IconButton(
                onPressed: () {
                  value.isPlaying ? controller.pause() : controller.play();
                },
                iconSize: 64,
                color: Colors.white,
                icon: Icon(
                  value.isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_circle_fill,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// A dual-handle range slider for trimming
class _TrimRangeSlider extends StatefulWidget {
  final double startFraction;
  final double endFraction;
  final double maxFraction;
  final void Function(double start, double end) onChanged;

  const _TrimRangeSlider({
    required this.startFraction,
    required this.endFraction,
    required this.maxFraction,
    required this.onChanged,
  });

  @override
  State<_TrimRangeSlider> createState() => _TrimRangeSliderState();
}

class _TrimRangeSliderState extends State<_TrimRangeSlider> {
  static const double _handleWidth = 20.0;
  static const double _height = 56.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final trackWidth = totalWidth - _handleWidth * 2;
          final startX = _handleWidth + widget.startFraction * trackWidth;
          final endX = _handleWidth + widget.endFraction * trackWidth;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (details) {
              final dx = details.localPosition.dx;
              final midX = (startX + endX) / 2;
              final maxF = widget.maxFraction;
              final windowSize = widget.endFraction - widget.startFraction;

              if (dx < midX) {
                // Moving start handle — keep window size fixed if at max
                double newStart = ((dx - _handleWidth) / trackWidth).clamp(0.0, widget.endFraction - 0.02);
                double newEnd = widget.endFraction;
                // If window exceeds max, push end back
                if (newEnd - newStart > maxF) {
                  newEnd = (newStart + maxF).clamp(0.0, 1.0);
                }
                widget.onChanged(newStart, newEnd);
              } else {
                // Moving end handle
                double newEnd = ((dx - _handleWidth) / trackWidth).clamp(widget.startFraction + 0.02, 1.0);
                double newStart = widget.startFraction;
                // If window exceeds max, push start forward
                if (newEnd - newStart > maxF) {
                  newStart = (newEnd - maxF).clamp(0.0, 1.0);
                }
                widget.onChanged(newStart, newEnd);
              }
            },
            child: Stack(
              children: [
                // Background track
                Positioned.fill(
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                // Selected range highlight
                Positioned(
                  left: startX,
                  right: totalWidth - endX,
                  top: 16,
                  bottom: 16,
                  child: Container(
                    color: AppColors.primary.withValues(alpha: 0.4),
                  ),
                ),
                // Start handle
                Positioned(
                  left: startX - _handleWidth,
                  top: 0,
                  bottom: 0,
                  width: _handleWidth,
                  child: _Handle(isLeft: true),
                ),
                // End handle
                Positioned(
                  left: endX,
                  top: 0,
                  bottom: 0,
                  width: _handleWidth,
                  child: _Handle(isLeft: false),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _Handle extends StatelessWidget {
  final bool isLeft;

  const _Handle({required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.horizontal(
          left: isLeft ? const Radius.circular(6) : Radius.zero,
          right: isLeft ? Radius.zero : const Radius.circular(6),
        ),
      ),
      child: Center(
        child: Icon(Icons.drag_handle, color: Colors.black54, size: 14),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;

  const _InfoCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
