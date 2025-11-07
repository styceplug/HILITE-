import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/utils/app_constants.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Dimensions.screenHeight,
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height50,
      ),
      child: Column(
        children: [
          SizedBox(height: Dimensions.height20),
          Row(
            children: [
              Icon(Iconsax.people, size: Dimensions.iconSize24),
              Spacer(),
              Icon(Iconsax.edit_2, size: Dimensions.iconSize24),
              SizedBox(width: Dimensions.width20),
              InkWell(
                onTap: (){
                  Get.toNamed(AppRoutes.settingsScreen);
                },
                child: Icon(Iconsax.more_circle, size: Dimensions.iconSize24),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height20),
          Stack(
            children: [
              Container(
                height: Dimensions.height10 * 15,
                width: Dimensions.width10 * 15,
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.black),
                  gradient: AppColors.blueWhiteGradient.withOpacity(0.5),
                ),
                child: Image.asset(
                  AppConstants.getPngAsset('duck'),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: Dimensions.height10,
                right: Dimensions.width10,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: Dimensions.width5,
                    vertical: Dimensions.height5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.edit,
                    color: AppColors.white,
                    size: Dimensions.iconSize20,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: Dimensions.height20),
          Text(
            'John Doe',
            style: TextStyle(
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: Dimensions.height5 / Dimensions.height5),
          Text(
            'Football Player',
            style: TextStyle(
              fontSize: Dimensions.font14,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: Dimensions.height5),
          Text(
            'Lorem ipsum dolor sit amet consectetur. Dui integer pretium tempor mauris quam fames aliquet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Dimensions.font13,
              fontWeight: FontWeight.w400,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '345',
                    style: TextStyle(
                      fontSize: Dimensions.font22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Posts',
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                width: 0.5,
                height: Dimensions.height50,
                color: AppColors.grey4,
              ),
              Column(
                children: [
                  Text(
                    '46K',
                    style: TextStyle(
                      fontSize: Dimensions.font22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Followers',
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
                width: 0.5,
                height: Dimensions.height50,
                color: AppColors.grey4,
              ),
              Column(
                children: [
                  Text(
                    '120',
                    style: TextStyle(
                      fontSize: Dimensions.font22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Following',
                    style: TextStyle(
                      fontSize: Dimensions.font14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: Dimensions.height20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
                child: Text(
                  'Position: LB/RB',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
                child: Text(
                  'Height: 175cm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width10,
                  vertical: Dimensions.height5,
                ),
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
                child: Text(
                  'Weight: 100lbs',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: Dimensions.font13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.black,
                  ),
                ),
              ),
            ],
          ),


          SizedBox(height: Dimensions.height20),
          CustomButton(
            text: 'Edit Profile',
            onPressed: () {},
            backgroundColor: AppColors.primary,
            borderRadius: BorderRadius.circular(Dimensions.radius10),
          ),
          SizedBox(height: Dimensions.height10),
          Container(
            height: 0.5,
            width: Dimensions.screenWidth,
            color: AppColors.grey4,
          ),
          SizedBox(height: Dimensions.height20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: Dimensions.height100 * 2,
                width: Dimensions.screenWidth / 3.5,
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
              ),
              Container(
                height: Dimensions.height100 * 2,
                width: Dimensions.screenWidth / 3.5,
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
              ),
              Container(
                height: Dimensions.height100 * 2,
                width: Dimensions.screenWidth / 3.5,
                decoration: BoxDecoration(
                  color: AppColors.grey2,
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
