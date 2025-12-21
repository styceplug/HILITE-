import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/app_constants.dart';
import '../utils/colors.dart';
import '../utils/dimensions.dart';

class ProfileAvatar extends StatefulWidget {
  final XFile? avatarFile;
  final String? avatarUrl;

  final Function(XFile)? onImageSelected;

  const ProfileAvatar({
    super.key,
    this.onImageSelected,
    this.avatarFile,
    this.avatarUrl,
  });

  @override
  State<ProfileAvatar> createState() => _ProfileAvatarState();
}

class _ProfileAvatarState extends State<ProfileAvatar> {
  XFile? selectedImage;
  String? avatarUrl;
  UserController userController = Get.find<UserController>();

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
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (image != null) {
      final fileSize = await image.length();
      if (fileSize > 5 * 1024 * 1024) {
        CustomSnackBar.failure(message: "Image must be less than 5MB");
        return;
      }

      setState(() {
        selectedImage = image;
      });

      widget.onImageSelected!(image); // pass to controller
    }
  }

  ImageProvider? _getImageProvider() {
    if (selectedImage != null) {
      return FileImage(File(selectedImage!.path));
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return NetworkImage(
        "$avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}",
      );
    } else {
      return null;
    }
  }

  Widget? _getImageWidget() {
    if (selectedImage != null) {
      return Container(
        height: Dimensions.height100,
        width: Dimensions.width100,
        decoration: BoxDecoration(
          color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary),
          image: DecorationImage(
            fit: BoxFit.cover,
            image: FileImage(File(selectedImage!.path)),
          ),
        ),
      );
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      return Container(
        height: Dimensions.height100 ,
        width: Dimensions.width100 ,
        decoration: BoxDecoration(
          // color: AppColors.error,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.primary),
        ),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: "$avatarUrl",
          ),
        ),
      );
    }
  }

  late final bool isMyProfile =
      (userController.othersProfile.value?.id == null) ||
      userController.othersProfile.value?.id == userController.user.value?.id;

  @override
  Widget build(BuildContext context) {
    final image = _getImageWidget();

    return Stack(
      children: [
        GestureDetector(
          onTap: isMyProfile ? pickImage : null,
          child:
              image != null
                  ? image
                  // ? Container(
                  //   height: Dimensions.height100 * 1.5,
                  //   width: Dimensions.width100 * 1.5,
                  //   decoration: BoxDecoration(
                  //     color: AppColors.error,
                  //     shape: BoxShape.circle,
                  //     border: Border.all(color: AppColors.primary),
                  //     image: DecorationImage(fit: BoxFit.cover, image: image),
                  //   ),
                  // )
                  : Container(
                    height: Dimensions.height100 * 1.5,
                    width: Dimensions.width100 * 1.5,
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.white,
                      size: Dimensions.iconSize30 * 3,
                    ),
                  ),
        ),
        if (isMyProfile)
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
