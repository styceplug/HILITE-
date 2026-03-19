

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';

import '../data/services/upload_services.dart';

class UploadProgressPill extends StatelessWidget {
  const UploadProgressPill({super.key});

  @override
  Widget build(BuildContext context) {
    // Guard: only render if service is registered
    if (!Get.isRegistered<UploadService>()) return const SizedBox.shrink();
    final service = Get.find<UploadService>();

    return Obx(() {
      final state = service.state.value;

      // Invisible when idle
      if (state.status == UploadStatus.idle) return const SizedBox.shrink();

      return Positioned(
        right: Dimensions.width20,
        top: Dimensions.height100,
        child: _PillCard(state: state, service: service),
      );
    });
  }
}

// ---------------------------------------------------------------------------
// _PillCard
// ---------------------------------------------------------------------------

class _PillCard extends StatefulWidget {
  const _PillCard({required this.state, required this.service});

  final UploadState state;
  final UploadService service;

  @override
  State<_PillCard> createState() => _PillCardState();
}

class _PillCardState extends State<_PillCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _slideY;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _slideY = Tween<double>(begin: 40, end: 0).animate(
      CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _slideY.value),
        child: FadeTransition(opacity: _fade, child: child),
      ),
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    final state = widget.state;
    final isSuccess = state.status == UploadStatus.success;
    final isFailure = state.status == UploadStatus.failure;
    final isDone = isSuccess || isFailure;

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E), // dark glass feel
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 8, 8),
              child: Row(
                children: [
                  _Thumbnail(path: state.thumbnailPath, isDone: isDone, isFailure: isFailure),
                  const SizedBox(width: 10),
                  Expanded(child: _Labels(state: state)),
                  _ActionButton(state: state, service: widget.service),
                ],
              ),
            ),

            // Progress bar (hidden when done)
            if (!isDone)
              _ProgressBar(progress: state.progress),

            // Success / failure strip
            if (isDone)
              _StatusStrip(isSuccess: isSuccess),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sub-widgets
// ---------------------------------------------------------------------------

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({
    required this.path,
    required this.isDone,
    required this.isFailure,
  });

  final String? path;
  final bool isDone;
  final bool isFailure;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white10,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail image
          if (path != null && path!.isNotEmpty)
            Image.file(File(path!), fit: BoxFit.cover)
          else
            const Icon(Icons.videocam_rounded, color: Colors.white38, size: 22),

          // Overlay icon on done states
          if (isDone)
            Container(
              color: Colors.black54,
              child: Center(
                child: Icon(
                  isFailure
                      ? Icons.error_outline_rounded
                      : Icons.check_circle_rounded,
                  color: isFailure ? const Color(0xFFFF453A) : const Color(0xFF30D158),
                  size: 22,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Labels extends StatelessWidget {
  const _Labels({required this.state});

  final UploadState state;

  @override
  Widget build(BuildContext context) {
    final isSuccess = state.status == UploadStatus.success;
    final isFailure = state.status == UploadStatus.failure;
    final isUploading = state.status == UploadStatus.uploading;

    String title;
    String subtitle;

    if (isSuccess) {
      title = 'Upload complete';
      subtitle = 'Your post is live 🎉';
    } else if (isFailure) {
      title = 'Upload failed';
      subtitle = 'Tap × to dismiss';
    } else {
      final pct = (state.progress * 100).toStringAsFixed(0);
      title = 'Uploading…';
      subtitle = '$pct%';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(
            color: isFailure
                ? const Color(0xFFFF453A)
                : Colors.white.withOpacity(0.55),
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.state, required this.service});

  final UploadState state;
  final UploadService service;

  @override
  Widget build(BuildContext context) {
    final isUploading = state.status == UploadStatus.uploading;

    return GestureDetector(
      onTap: () {
        if (isUploading) {
          service.cancel();
        } else {
          service.dismissPill();
        }
      },
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.10),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.close_rounded,
          size: 14,
          color: Colors.white.withOpacity(0.7),
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      builder: (_, value, __) {
        return Container(
          height: 3,
          decoration: const BoxDecoration(
            color: Colors.white10,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A84FF), Color(0xFF30D158)],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatusStrip extends StatelessWidget {
  const _StatusStrip({required this.isSuccess});

  final bool isSuccess;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 3,
      color: isSuccess ? const Color(0xFF30D158) : const Color(0xFFFF453A),
    );
  }
}