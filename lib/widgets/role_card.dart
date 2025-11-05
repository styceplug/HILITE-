import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/app_constants.dart';

class RoleCard extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.title,
    required this.description,
    required this.image,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: Dimensions.width10,
          vertical: Dimensions.height10,
        ),
        margin: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height10),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.info,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          color: isSelected ? AppColors.primary.withOpacity(0.05) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              height: Dimensions.height100,
              width: Dimensions.width100,
              padding: EdgeInsets.all(Dimensions.width10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(Dimensions.radius10),
              ),
              child: Image.asset(AppConstants.getPngAsset(image)),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10 / 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: Dimensions.font12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.grey5,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: Dimensions.width20),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.grey5,
              size: Dimensions.iconSize24,
            ),
          ],
        ),
      ),
    );
  }
}