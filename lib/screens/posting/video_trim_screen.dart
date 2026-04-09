import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/app_loading_overlay.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimScreen extends StatefulWidget {
  final XFile file;

  const VideoTrimScreen({super.key, required this.file});

  @override
  State<VideoTrimScreen> createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();

  bool _isLoadingVideo = true;
  bool _isSavingVideo = false;
  bool _isPlaying = false;
  String? _loadError;

  double _startValue = 0;
  double _endValue = 0;
  double _videoDurationSeconds = 0;

  double get _effectiveEndValue {
    if (_endValue > _startValue) {
      return _endValue;
    }

    if (_videoDurationSeconds > _startValue) {
      return _videoDurationSeconds;
    }

    return _startValue;
  }

  bool get _shouldUseOriginal {
    if (_videoDurationSeconds <= 0) {
      return true;
    }

    final endDelta = (_videoDurationSeconds - _effectiveEndValue).abs();
    return _startValue <= 0.05 && endDelta <= 0.05;
  }

  double get _selectedDurationSeconds {
    final selectedDuration = _effectiveEndValue - _startValue;
    return selectedDuration > 0 ? selectedDuration : 0;
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  Future<void> _loadVideo() async {
    final videoFile = File(widget.file.path);

    if (!videoFile.existsSync()) {
      setState(() {
        _isLoadingVideo = false;
        _loadError = 'The selected video could not be found.';
      });
      return;
    }

    try {
      await _trimmer.loadVideo(videoFile: videoFile);

      final duration =
          _trimmer.videoPlayerController?.value.duration ?? Duration.zero;
      final durationSeconds = duration.inMilliseconds / 1000;

      if (!mounted) return;

      setState(() {
        _videoDurationSeconds = durationSeconds;
        _startValue = 0;
        _endValue = durationSeconds;
        _isLoadingVideo = false;
        _loadError = null;
      });
    } catch (e) {
      debugPrint('Video trim load error: $e');

      if (!mounted) return;

      setState(() {
        _isLoadingVideo = false;
        _loadError = 'Could not open this video for editing.';
      });
    }
  }

  Future<void> _togglePlayback() async {
    if (_isLoadingVideo || _isSavingVideo || _loadError != null) {
      return;
    }

    try {
      final isPlaying = await _trimmer.videoPlaybackControl(
        startValue: _startValue,
        endValue: _effectiveEndValue,
      );

      if (!mounted) return;
      setState(() => _isPlaying = isPlaying);
    } catch (e) {
      debugPrint('Video trim playback error: $e');
    }
  }

  Future<void> _continueToPostDetails({bool useOriginal = false}) async {
    if (_isSavingVideo) return;

    if (useOriginal || _loadError != null || _shouldUseOriginal) {
      _openPostDetails(widget.file);
      return;
    }

    if (_selectedDurationSeconds < 0.1) {
      CustomSnackBar.failure(
        message: 'Select a longer part of the video to continue.',
      );
      return;
    }

    try {
      setState(() => _isSavingVideo = true);

      if (_isPlaying) {
        await _togglePlayback();
      }

      final completer = Completer<String?>();

      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _effectiveEndValue,
        onSave: (outputPath) {
          if (!completer.isCompleted) {
            completer.complete(outputPath);
          }
        },
      );

      final outputPath = await completer.future.timeout(
        const Duration(minutes: 2),
        onTimeout: () => null,
      );

      if (!mounted) return;

      if (outputPath == null || outputPath.isEmpty) {
        setState(() => _isSavingVideo = false);
        CustomSnackBar.failure(
          message: 'Could not trim this video. Try again.',
        );
        return;
      }

      _openPostDetails(XFile(outputPath));
    } catch (e) {
      debugPrint('Video trim save error: $e');

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

  String _formatDuration(double seconds) {
    final totalSeconds = seconds.isFinite ? seconds.round() : 0;
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    if (duration.inHours > 0) {
      final hours = duration.inHours.toString().padLeft(2, '0');
      return '$hours:$minutes:$remainingSeconds';
    }

    return '$minutes:$remainingSeconds';
  }

  @override
  void dispose() {
    _trimmer.videoPlayerController?.pause();
    _trimmer.dispose();
    super.dispose();
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

    if (_loadError != null) {
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
                _loadError!,
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

    final aspectRatio =
        _trimmer.videoPlayerController?.value.aspectRatio ?? (9 / 16);
    final viewerWidth = MediaQuery.of(context).size.width - 32;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adjust the handles to choose the part of the video you want to upload.',
          style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white12),
          ),
          child: AspectRatio(
            aspectRatio: aspectRatio > 0 ? aspectRatio : (9 / 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: VideoViewer(trimmer: _trimmer),
            ),
          ),
        ),
        const SizedBox(height: 20),
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
              TrimViewer(
                trimmer: _trimmer,
                viewerHeight: 56,
                viewerWidth: viewerWidth,
                onChangeStart: (value) => setState(() => _startValue = value),
                onChangeEnd: (value) => setState(() => _endValue = value),
                onChangePlaybackState:
                    (value) => setState(() => _isPlaying = value),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _InfoCard(
                      label: 'Start',
                      value: _formatDuration(_startValue),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      label: 'Selected',
                      value: _formatDuration(_selectedDurationSeconds),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _InfoCard(
                      label: 'End',
                      value: _formatDuration(_effectiveEndValue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        Center(
          child: IconButton(
            onPressed: _togglePlayback,
            iconSize: 64,
            color: Colors.white,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
            ),
          ),
        ),
      ],
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
