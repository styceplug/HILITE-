import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';


class ProfileAvatar extends StatefulWidget {
  final XFile? avatarFile; // pass initial XFile if you have
  final String? avatarUrl;

  final Function(XFile) onImageSelected;

  const ProfileAvatar({
    super.key,
    required this.onImageSelected,
    this.avatarFile,
    this.avatarUrl,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  XFile? selectedImage;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.avatarFile;
    avatarUrl = widget.avatarUrl;
  }

  @override
  void didUpdateWidget(ProfileAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatarUrl != widget.avatarUrl) {
      setState(() {
        avatarUrl = widget.avatarUrl;
        selectedImage = null; // reset selected file
      });
    }
  }

  void pickImage() async {
    final picker = ImagePicker();
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (image != null) {
      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        CustomSnackBar.failure(message: "Image must be less than 5MB");
        return;
      }

      setState(() {
        selectedImage = image; // immediately show local preview
      });

      widget.onImageSelected(image); // pass to controller
    }
  }

  ImageProvider _getImageProvider() {
    if (selectedImage != null) {
      return FileImage(File(selectedImage!.path));
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      // add timestamp to force refresh after upload
      return NetworkImage("$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}");
    } else {
      return AssetImage(AppConstants.getPngAsset('user')) as ImageProvider;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: Dimensions.height100 * 1.5,
            width: Dimensions.width100 * 1.5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                fit: BoxFit.cover,
                image: _getImageProvider(),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.error,
            child: Icon(
              Icons.edit,
              size: Dimensions.iconSize20,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}