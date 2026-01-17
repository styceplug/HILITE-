import 'package:flutter/material.dart';
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
    final double cardRadius = Dimensions.radius15;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 0, Dimensions.width15, 0),
        margin: EdgeInsets.symmetric(
          horizontal: Dimensions.width20,
          vertical: Dimensions.height10,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.white,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          color: AppColors.white,
        ),
        height: Dimensions.height100 * 1.2,
        child: Row(
          children: [
            // --- IMAGE SECTION (Fixed Width) ---
            Stack(
              children: [
                Container(
                  width: Dimensions.width100 * 1.4,
                  height: Dimensions.height100 * 1.2,
                  padding: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(cardRadius),
                      bottomLeft: Radius.circular(cardRadius),
                    ),
                    image: DecorationImage(
                      image: AssetImage(AppConstants.getPngAsset(image)),
                      fit: BoxFit.fitHeight,
                    ),
                  ),
                ),
                // Gradient Overlay
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(cardRadius),
                        bottomLeft: Radius.circular(cardRadius),
                      ),
                      color: AppColors.black.withOpacity(0.1),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: Dimensions.width20),

            // --- TEXT SECTION (Flexible Width) ---
            // ERROR FIX: Wrapped Padding in Expanded to prevent overflow
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center, // Centers text vertically
                  children: [
                    // Removed Expanded from Title so it only takes needed space
                    Text(
                      title,
                      maxLines: 1, // Title usually stays on one line
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: Dimensions.font15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        description,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: Dimensions.font12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.grey5,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(width: Dimensions.width20),

            // --- ICON SECTION (Fixed Width) ---
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