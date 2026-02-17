import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/home/pages/profile_screen.dart';
import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';


import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

import '../screens/home/pages/profile_screen.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class _AvatarShell extends StatelessWidget {
  final Widget child;
  final double size;

  const _AvatarShell({
    required this.child,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.primary, width: 2),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            spreadRadius: 1,
            offset: Offset(0, 8),
            color: Color(0x22000000),
          ),
        ],
      ),
      child: ClipOval(child: child),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  final double size;

  const _AvatarPlaceholder({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: (Dimensions.iconSize30 * 3),
      ),
    );
  }
}

class _AvatarNetworkImage extends StatelessWidget {
  final String url;

  const _AvatarNetworkImage({required this.url});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: url,
      fit: BoxFit.cover,
      fadeInDuration: const Duration(milliseconds: 160),
      placeholder: (_, __) => const Center(
        child: SizedBox(
          height: 26,
          width: 26,
          child: CircularProgressIndicator(strokeWidth: 2.6),
        ),
      ),
      errorWidget: (_, __, ___) => const Center(
        child: Icon(Icons.person, size: 80),
      ),
    );
  }
}

class _SheetTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final bool isDestructive;

  const _SheetTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: iconColor.withOpacity(.12),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? Colors.red : const Color(0xFF111827),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
            ],
          ),
        ),
      ),
    );
  }
}

class MyProfileAvatar extends StatefulWidget {
  final String? avatarUrl;

  /// Optional: if you want to immediately reflect local picked file in parent too
  final Function(XFile file)? onImageSelected;

  const MyProfileAvatar({
    super.key,
    this.avatarUrl,
    this.onImageSelected,
  });

  @override
  State<MyProfileAvatar> createState() => _MyProfileAvatarState();
}

class _MyProfileAvatarState extends State<MyProfileAvatar> {
  final AuthController authController = Get.find<AuthController>();
  final ImagePicker _picker = ImagePicker();

  XFile? _localImage;

  double get _size => Dimensions.height150;

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image == null) return;

    final fileSize = await image.length();
    if (fileSize > 5 * 1024 * 1024) {
      CustomSnackBar.failure(message: "Image must be less than 5MB");
      return;
    }

    setState(() => _localImage = image);
    widget.onImageSelected?.call(image);
  }

  void _openViewer() {
    final url = widget.avatarUrl;
    // Only view server image (same behavior you had)
    if (url != null && url.isNotEmpty) {
      Get.to(() => ProfileImageViewer(imageUrl: url));
    }
  }

  void _showEditOptions() {
    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Profile photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),

              _SheetTile(
                icon: Icons.photo_library,
                iconColor: const Color(0xFF2563EB),
                title: "Upload new photo",
                onTap: () {
                  Get.back();
                  _pickImage();
                },
              ),

              if ((widget.avatarUrl ?? "").isNotEmpty)
                _SheetTile(
                  icon: Icons.delete_outline,
                  iconColor: Colors.red,
                  title: "Remove photo",
                  isDestructive: true,
                  onTap: () {
                    Get.back();
                    _confirmDelete();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete() {
    Get.dialog(
      AlertDialog(
        title: const Text("Remove photo?"),
        content: const Text("This will remove your profile picture."),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back();

              // Call your controller method
              await authController.deleteAvatar();

              // Clear local preview too
              if (mounted) setState(() => _localImage = null);
            },
            child: const Text(
              "Remove",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // 1) Local selected image preview
    if (_localImage != null) {
      return _AvatarShell(
        size: _size,
        child: Image.file(
          File(_localImage!.path),
          fit: BoxFit.cover,
        ),
      );
    }

    // 2) Network image
    final url = widget.avatarUrl;
    if (url != null && url.isNotEmpty) {
      return _AvatarShell(
        size: _size,
        child: _AvatarNetworkImage(url: url),
      );
    }

    // 3) Placeholder
    return _AvatarPlaceholder(size: _size);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: _openViewer,
          child: _buildImage(),
        ),

        Positioned(
          bottom: 6,
          right: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: _showEditOptions,
              child: Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 14,
                      offset: Offset(0, 6),
                      color: Color(0x33000000),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, size: 18, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OtherProfileAvatar extends StatelessWidget {
  final String? avatarUrl;

  const OtherProfileAvatar({
    super.key,
    this.avatarUrl,
  });

  double get _size => Dimensions.height150;

  void _openViewer() {
    final url = avatarUrl;
    if (url != null && url.isNotEmpty) {
      Get.to(() => ProfileImageViewer(imageUrl: url));
    }
  }

  Widget _buildImage() {
    final url = avatarUrl;

    if (url != null && url.isNotEmpty) {
      return _AvatarShell(
        size: _size,
        child: _AvatarNetworkImage(url: url),
      );
    }

    return _AvatarPlaceholder(size: _size);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openViewer,
      child: _buildImage(),
    );
  }
}
