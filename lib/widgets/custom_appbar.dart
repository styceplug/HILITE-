import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/app_constants.dart';
import '../utils/dimensions.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? customTitle;
  final String? title;
  final String? titleImage;
  final String? subtitle;
  final Widget? leadingIcon;
  final Widget? actionIcon;
  final Color? backgroundColor;
  final Color? titleColor;
  final bool centerTitle;
  final double elevation;

  const CustomAppbar({
    super.key,
    this.title,
    this.customTitle,
    this.titleImage,
    this.subtitle,
    this.leadingIcon,
    this.actionIcon,
    this.backgroundColor =Colors.white,
    this.titleColor,
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      elevation: elevation,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading:
          leadingIcon != null
              ? Padding(
                padding: EdgeInsets.only(left: Dimensions.width10),
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: leadingIcon,
                ),
              )
              : null,
      title:
          customTitle ??
          (title != null
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (titleImage != null)
                        SizedBox(
                          height: Dimensions.height33,
                          child: Image.asset(
                            AppConstants.getPngAsset(titleImage!),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (titleImage != null)
                        SizedBox(width: Dimensions.width5),
                      Text(
                        title!,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color:
                              titleColor ?? theme.textTheme.titleLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: (titleColor ??
                                theme.textTheme.titleMedium?.color)
                            ?.withOpacity(0.8),
                        fontSize: Dimensions.font14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              )
              : null),
      actions:
          actionIcon != null
              ? [
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: actionIcon,
                ),
              ]
              : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 8);
}
