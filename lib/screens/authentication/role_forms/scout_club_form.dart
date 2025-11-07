import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/country_state_dropdown.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class ScoutClubForm extends StatefulWidget {
  const ScoutClubForm({super.key});

  @override
  State<ScoutClubForm> createState() => _ScoutClubFormState();
}

class _ScoutClubFormState extends State<ScoutClubForm> {
  final formKey = GlobalKey<FormState>();
  String selectedProfileType = '';
  String? selectedCountry;
  String? selectedState;
  String selectedClubType = '';
  String headCoachOrManager = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
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
                        'AGENTS & CLUBS',
                        style: TextStyle(
                          fontFamily: 'BebasNeue',
                          fontSize: Dimensions.font30 * 4,
                          color: AppColors.white.withOpacity(0.08),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimensions.width20,
                        vertical: Dimensions.height50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HILITE',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: Dimensions.font30,
                              color: AppColors.white,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            'AGENT / CLUB PROFILE SETUP',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: Dimensions.font30 * 1.2,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                          SizedBox(height: Dimensions.height10),
                          Text(
                            'Kindly select your profile type and fill in the required details.',
                            style: TextStyle(
                              fontSize: Dimensions.font15,
                              color: AppColors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),


              Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Profile Type",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: Dimensions.font18,
                      ),
                    ),
                    SizedBox(height: Dimensions.height10),

                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              selectedProfileType = 'agent';
                            }),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              decoration: BoxDecoration(
                                color: selectedProfileType == 'agent'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(color: AppColors.primary),
                                borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Scout / Agent',
                                style: TextStyle(
                                  color: selectedProfileType == 'agent'
                                      ? AppColors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: Dimensions.width10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() {
                              selectedProfileType = 'club';
                            }),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                vertical: Dimensions.height15,
                              ),
                              decoration: BoxDecoration(
                                color: selectedProfileType == 'club'
                                    ? AppColors.primary
                                    : Colors.transparent,
                                border: Border.all(color: AppColors.primary),
                                borderRadius:
                                BorderRadius.circular(Dimensions.radius15),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Football Club',
                                style: TextStyle(
                                  color: selectedProfileType == 'club'
                                      ? AppColors.white
                                      : AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: Dimensions.height30),


                    if (selectedProfileType == 'agent') _buildAgentForm(),
                    if (selectedProfileType == 'club') _buildClubForm(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAgentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        CustomTextField(labelText: "Contact Number", keyboardType: TextInputType.phone),
        SizedBox(height: Dimensions.height20),
        CustomTextField(labelText: "Agency Name"),
        SizedBox(height: Dimensions.height20),
        CustomTextField(labelText: "License / Registration ID"),
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
        CustomTextField(labelText: "Experience / Players Represented"),
        SizedBox(height: Dimensions.height30),
        CustomButton(
          text: "Submit Agent Profile",
          onPressed: () {
            if (formKey.currentState!.validate()) {
              // submit logic
            }
          },
        ),
        SizedBox(height: Dimensions.height50),
      ],
    );
  }


  Widget _buildClubForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(labelText: "Club Name"),
        SizedBox(height: Dimensions.height20),
        CustomTextField(labelText: "Contact Number", keyboardType: TextInputType.phone),
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
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius20),
                  topRight: Radius.circular(Dimensions.radius20),
                ),
              ),
              builder: (_) {
                return _buildBottomPicker(
                  title: "Select Role",
                  options: ["Head Coach", "Manager"],
                  onSelected: (value) {
                    setState(() {
                      headCoachOrManager = value;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
          child: _buildPickerContainer(
            title: "Head Coach / Manager",
            value: headCoachOrManager,
          ),
        ),
        SizedBox(height: Dimensions.height20),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(Dimensions.radius20),
                  topRight: Radius.circular(Dimensions.radius20),
                ),
              ),
              builder: (_) {
                return _buildBottomPicker(
                  title: "Select Club Type",
                  options: ["Academy", "Amateur", "Professional"],
                  onSelected: (value) {
                    setState(() {
                      selectedClubType = value;
                    });
                    Navigator.pop(context);
                  },
                );
              },
            );
          },
          child: _buildPickerContainer(
            title: "Club Type (Academy / Amateur / Professional)",
            value: selectedClubType,
          ),
        ),
        SizedBox(height: Dimensions.height20),
        CustomTextField(labelText: "Year Founded (YYYY)", keyboardType: TextInputType.number),
        SizedBox(height: Dimensions.height30),
        CustomButton(
          text: "Submit Club Profile",
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Get.toNamed(AppRoutes.verifyProfileScreen);
            }
          },
        ),
        SizedBox(height: Dimensions.height50),
      ],
    );
  }

  Widget _buildPickerContainer({required String title, required String value}) {
    return Container(
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width10,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      child: Text(
        value.isEmpty ? title : value,
        style: TextStyle(
          color: value.isEmpty
              ? AppColors.black.withOpacity(0.5)
              : AppColors.black,
          fontSize: Dimensions.font15,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }

  Widget _buildBottomPicker({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width20,
        vertical: Dimensions.height20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'BebasNeue',
              fontSize: Dimensions.font20,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: Dimensions.height10),
          ...options.map(
                (option) => ListTile(
              title: Text(option),
              onTap: () => onSelected(option),
            ),
          ),
        ],
      ),
    );
  }
}