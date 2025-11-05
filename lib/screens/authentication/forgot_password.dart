import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
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
                  right: -Dimensions.width100 * 2,
                  bottom: Dimensions.height20,
                  child: Text(
                    'FORGOT PASSWORD',
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
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                      ),
                      child: Text(
                        'FORGOT PASSWORD?',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: Dimensions.font30 * 1.2,
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
                CustomTextField(hintText: 'Input Email Address'),
                SizedBox(height: Dimensions.height20),

                CustomButton(text: 'SIGN IN', onPressed: () {}),
                SizedBox(height: Dimensions.height20),
                Text(
                  'If there is an existing record attached to provided mail, a password reset link will be sent to your email',
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
