import 'package:flutter/material.dart';

import '../utils/app_constants.dart';
import '../utils/dimensions.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final String? imageAsset;


  const EmptyState({super.key, required this.message, this.imageAsset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;

    return SizedBox(
      height: Dimensions.screenHeight,
      width: Dimensions.screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: Dimensions.height100 ,
            width: Dimensions.width100 ,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(AppConstants.getPngAsset(imageAsset!)),
              ),
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            message,
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: Dimensions.height20 * 10),
        ],
      ),
    );
  }
}
