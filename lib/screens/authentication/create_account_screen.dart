import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            height: Dimensions.screenHeight / 3,
            width: Dimensions.screenWidth,
            padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
            color: AppColors.primary,
            child: Stack(
              children: [
                Positioned(
                  right: -Dimensions.width100 * 4,
                  bottom: Dimensions.height20,
                  child: Text(
                    'CREATE ACCOUNT',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: Dimensions.font30 * 4,
                      color: AppColors.white.withOpacity(0.1),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height50,
                      ),
                      child: Text(
                        'HILITE',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: Dimensions.font30,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    Spacer(),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                      ),
                      child: Text(
                        'CREATE AN ACCOUNT TODAY!',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: Dimensions.font30 * 1.2,
                          color: AppColors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                      ),
                      child: Text(
                        'Get news,game updates highlights and more info on your favorite teams',
                        style: TextStyle(
                          fontSize: Dimensions.font16,
                          color: AppColors.white,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: Dimensions.height20),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimensions.width20,
              vertical: Dimensions.height20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextField(hintText: 'Full Name'),
                SizedBox(height: Dimensions.height20),
                CustomTextField(hintText: 'Username'),
                SizedBox(height: Dimensions.height20),
                CustomTextField(hintText: 'Email Address'),
                SizedBox(height: Dimensions.height20),
                CustomTextField(
                  hintText: 'Password',
                  suffixIcon: Icon(Icons.visibility),
                ),
                SizedBox(height: Dimensions.height20),
                Text(
                  'Password must be at least 8 character long and include 1 capital letter and 1 symbol',
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: AppColors.grey5,
                    fontSize: Dimensions.font13,
                  ),
                ),
                SizedBox(height: Dimensions.height20),
                Row(
                  children: [
                    Icon(Icons.check_box_outline_blank),
                    SizedBox(width: Dimensions.width5),
                    Text(
                      'I agree to  the Terms and Privacy Policy',
                      style: TextStyle(
                        color: AppColors.grey5,
                        fontSize: Dimensions.font13,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: Dimensions.height20),
                CustomButton(text: 'CREATE ACCOUNT', onPressed: () {
                  Get.toNamed(AppRoutes.selectCategoryScreen);
                }),
                SizedBox(height: Dimensions.height20),
                Text(
                  'By agreeing to the above terms, you are consenting that your personal information will be collected, stored, and processed on behalf of HILITE',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: AppColors.grey5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
