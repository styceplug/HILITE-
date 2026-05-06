import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/snackbars.dart';

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
  AuthController authController = Get.find<AuthController>();
  TextEditingController mailController = TextEditingController();

  void requestLink() {
    if (mailController.text.isEmpty) {
      CustomSnackBar.failure(message: 'Please enter your email address');
      return;
    }
    final mail = mailController.text.trim();
    authController.initiatePasswordReset(mail);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(leadingIcon: BackButton(color: AppColors.textColor)),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Forgot Password?',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Dimensions.font25,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: Dimensions.height5),
            Text(
              'We will send a password reset link to your email.',
              style: TextStyle(
                color: AppColors.textColor,
                fontSize: Dimensions.font14,
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: Dimensions.height50),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                CustomTextField(
                  hintText: 'Username or Email',
                  prefixIcon: CupertinoIcons.person_crop_circle,
                  controller: mailController,
                  // labelText: 'Email Address',
                  autofillHints: [AutofillHints.email],
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: Dimensions.height20),

                CustomButton(
                  text: 'Reset Password',
                  onPressed: () {
                    requestLink();
                  },
                  backgroundColor: AppColors.buttonColor,
                ),
                /*SizedBox(height: Dimensions.height20),
                Text(
                  'If there is an existing record attached to provided mail, a password reset link will be sent to your email',
                  textAlign: TextAlign.justify,
                  style: TextStyle(color: AppColors.grey5),
                ),*/
              ],
            ),
          ],
        ),
      ),
    );
  }
}
