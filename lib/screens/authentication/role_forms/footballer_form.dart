import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/country_state_dropdown.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class FootballerForm extends StatefulWidget {
  const FootballerForm({super.key});

  @override
  State<FootballerForm> createState() => _FootballerFormState();
}

class _FootballerFormState extends State<FootballerForm> {
  final formKey = GlobalKey<FormState>();
  String? selectedCountry;
  String? selectedState;


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: Dimensions.screenHeight / 3,
                width: Dimensions.screenWidth,
                color: AppColors.primary,
                child: Stack(
                  children: [
                    Positioned(
                      right: -Dimensions.width100 * 2,
                      bottom: Dimensions.height20,
                      child: Text(
                        'PLAYER PROFILE',
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
                            'PLAYER PROFILE SETUP',
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: Dimensions.width20,vertical: Dimensions.height20),
                child: Column(
                  children: [

                    CustomTextField(labelText: "Date of Birth (DD/MM/YYYY)",keyboardType: TextInputType.datetime),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(labelText: "Contact Number",keyboardType: TextInputType.phone),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(labelText: "Playing Position",keyboardType: TextInputType.name ),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(labelText: "Preferred Foot (Left / Right)"),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(labelText: "Current Club Name / Free Agent"),
                    SizedBox(height: Dimensions.height20),
                    Row(
                      children: [
                        Expanded(child: CustomTextField(labelText: "Height (cm or ft)")),
                        const SizedBox(width: 10),
                        Expanded(child: CustomTextField(labelText: "Weight (kg or lbs)")),
                      ],
                    ),
                    SizedBox(height: Dimensions.height20),
                    CountryState(
                      selectedCountry: selectedCountry,
                      selectedState: selectedState,
                      onCountryChanged: (country) {
                        setState(() {
                          selectedCountry = country;
                          selectedState = null;
                        });
                      },
                      onStateChanged: (state) {
                        setState(() {
                          selectedState = state;
                        });
                      },
                    ),

                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      labelText: "Player Bio / Description",
                      maxLines: 4,
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomButton(
                      text: "Submit Player Profile",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Get.toNamed(AppRoutes.verifyProfileScreen);
                        }
                      },
                    ),
                    SizedBox(height: Dimensions.height50)
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
