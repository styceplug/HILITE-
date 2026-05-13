import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/widgets/custom_appbar.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/storage_helper.dart';
import '../../../widgets/country_state_dropdown.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../widgets/snackbars.dart';


class AgentProfileForm extends StatefulWidget {
  const AgentProfileForm({Key? key}) : super(key: key);

  @override
  State<AgentProfileForm> createState() => _AgentProfileFormState();
}

class _AgentProfileFormState extends State<AgentProfileForm> {
  final formKey = GlobalKey<FormState>();

  String? selectedCountry;
  String? selectedState;
  String? selectedRole;
  String? selectedExperience;
  bool isPasswordVisible = false;
  bool termsPolicy = false;
  Timer? debounceTimer;

  AuthController authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController agencyNameController = TextEditingController();

  // Options for Full Screen Pickers
  final List<Map<String, String>> roleOptions = [
    {"title": "Scout", "image": "jersey"},
    {"title": "Agent", "image": "cleats"},
    {"title": "Recruiter", "image": "logo3"},
  ];

  final List<Map<String, String>> experienceOptions = [
    {"title": "Local", "image": "jersey"},
    {"title": "International", "image": "logo3"},
  ];

  @override
  void dispose() {
    debounceTimer?.cancel();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    agencyNameController.dispose();
    super.dispose();
  }

  void togglePass() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void toggleTerms() {
    setState(() => termsPolicy = !termsPolicy);
  }

  // Generate username: lowercase and replace spaces with underscores
  String generateUsername(String fullName) {
    return fullName.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }

  Map<String, dynamic> agentBody() => {
    "name": nameController.text.trim(),
    "username": generateUsername(nameController.text),
    "email": emailController.text.trim(),
    "password": passwordController.text,
    "role": "agent",
    "agencyName": agencyNameController.text.trim(),
    "experience": selectedExperience?.toLowerCase(),
    "roleType": selectedRole?.toLowerCase(),
    "country": selectedCountry,
    "state": selectedState,
  };

  // --- REUSABLE FULL SCREEN PICKER ---
  void _openFullScreenPicker({
    required String title,
    required String? currentValue,
    required List<Map<String, String>> options,
    required Function(String) onSelected,
  }) {
    FocusScope.of(context).unfocus(); // Hide keyboard

    Get.to(
          () => Scaffold(
        backgroundColor: const Color(0xFF030A1B),
        appBar: CustomAppbar(
          title: title,
          backgroundColor: const Color(0xFF030A1B),
          leadingIcon: const BackButton(color: Colors.white),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(Dimensions.width20),
          itemCount: options.length,
          itemBuilder: (context, index) {
            final item = options[index];
            final isSelected = currentValue == item['title'];

            return GestureDetector(
              onTap: () {
                onSelected(item['title']!);
                Get.back();
              },
              child: Container(
                margin: EdgeInsets.only(bottom: Dimensions.height15),
                padding: EdgeInsets.all(Dimensions.width15),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(Dimensions.radius10),
                  border: Border.all(
                    color: isSelected ? AppColors.buttonColor : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Image.asset(
                      AppConstants.getPngAsset(item['image']!),
                      height: Dimensions.iconSize30 * 1.2,
                    ),
                    SizedBox(width: Dimensions.width15),
                    Text(
                      item['title']!,
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: Dimensions.font18,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const Spacer(),
                    if (isSelected)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.buttonColor,
                        size: Dimensions.iconSize24,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      transition: Transition.rightToLeft,
    );
  }

  Widget _buildPickerContainer({required String title, required String value, required String image}) {
    return Container(
      width: Dimensions.screenWidth,
      padding: EdgeInsets.symmetric(
        horizontal: Dimensions.width10,
        vertical: Dimensions.height15,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.textColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(Dimensions.radius10),
        color: AppColors.white.withOpacity(0.1),
      ),
      child: Row(
        children: [
          Image.asset(
            AppConstants.getPngAsset(image),
            height: Dimensions.iconSize30,
          ),
          SizedBox(width: Dimensions.width15),
          Text(
            value.isEmpty ? title : value,
            style: TextStyle(
              color: value.isEmpty
                  ? AppColors.textColor.withOpacity(0.5)
                  : AppColors.textColor,
              fontSize: Dimensions.font18,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const Spacer(),
          Icon(Icons.arrow_forward_ios_rounded, color: AppColors.textColor, size: Dimensions.iconSize16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: AppColors.backgroundColor,
        leadingIcon: BackButton(color: AppColors.textColor),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.getPngAsset('logo3'),
                height: Dimensions.height65,
              ),
              SizedBox(height: Dimensions.height20),

              Text(
                'Create your scout account',
                style: TextStyle(
                  fontSize: Dimensions.font23,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height5),

              Text(
                'Discover top talent and recruit the best',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  color: AppColors.textColor.withOpacity(0.8),
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      hintText: 'Full Name',
                      controller: nameController,
                      autofillHints: const [AutofillHints.name],
                      prefixIcon: CupertinoIcons.person_crop_circle,
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      hintText: 'Email',
                      prefixIcon: Icons.mail,
                      controller: emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      hintText: 'Password',
                      prefixIcon: Icons.lock,
                      maxLines: 1,
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      suffixIcon: InkWell(
                        onTap: togglePass,
                        child: Icon(
                          !isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      hintText: "Organization / Agency name (Optional)",
                      controller: agencyNameController,
                      maxLines: 1,
                      prefixIcon: CupertinoIcons.building_2_fill,
                    ),

                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap: () => _openFullScreenPicker(
                        title: "Role Type",
                        currentValue: selectedRole,
                        options: roleOptions,
                        onSelected: (val) {
                          setState(() {
                            selectedRole = val;
                          });
                        },
                      ),
                      child: _buildPickerContainer(
                        title: "Role Type",
                        value: selectedRole ?? '',
                        image: 'jersey',
                      ),
                    ),

                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap: () => _openFullScreenPicker(
                        title: "Experience Level (Optional)",
                        currentValue: selectedExperience,
                        options: experienceOptions,
                        onSelected: (val) {
                          setState(() {
                            selectedExperience = val;
                          });
                        },
                      ),
                      child: _buildPickerContainer(
                        title: "Experience Level (Optional)",
                        value: selectedExperience ?? '',
                        image: 'logo3', // Changed image to differentiate
                      ),
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

                    InkWell(
                      onTap: toggleTerms,
                      child: Row(
                        children: [
                          Icon(
                            termsPolicy ? Icons.toggle_on : Icons.toggle_off,
                            color: AppColors.buttonColor,
                            size: Dimensions.iconSize30 * 2,
                          ),
                          SizedBox(width: Dimensions.width5),
                          Text(
                            'I am 18 years or older',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: Dimensions.font13,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: Dimensions.height20),
                    Text(
                      'By signing up, you agree to our Terms of Service and Privacy Policy',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: Dimensions.font13,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomButton(
                      text: "Sign Up",
                      onPressed: () {
                        if (!termsPolicy) {
                          CustomSnackBar.failure(message: 'You must confirm you are 18 or older.');
                          return;
                        }
                        if (selectedRole == null) {
                          CustomSnackBar.failure(message: 'Please select a Role Type.');
                          return;
                        }
                        // Validate text fields before submitting
                        if (formKey.currentState!.validate()) {
                          authController.registerOthers(agentBody());
                        }
                      },
                    ),
                    SizedBox(height: Dimensions.height50),
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
