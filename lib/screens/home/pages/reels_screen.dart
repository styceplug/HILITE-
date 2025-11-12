import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';

class ReelsScreen extends StatefulWidget {
  const ReelsScreen({super.key});

  @override
  State<ReelsScreen> createState() => _ReelsScreenState();
}

class _ReelsScreenState extends State<ReelsScreen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          //reel
          Container(),
          //add post
          Positioned(
            bottom: Dimensions.height100*1.2+kBottomNavigationBarHeight,
            right: Dimensions.width20,
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle
                  ),
                  child: Icon(CupertinoIcons.heart,color: AppColors.white,),
                ),
                SizedBox(height: Dimensions.height20),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width20,
                    vertical: Dimensions.height20,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle
                  ),
                  child: Icon(CupertinoIcons.chat_bubble_text_fill,color: AppColors.white,),
                ),
                SizedBox(height: Dimensions.height20*5),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
