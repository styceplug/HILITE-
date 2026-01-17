import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:intl/intl.dart';

import '../../../routes/routes.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/storage_helper.dart';
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
  AuthController authController = Get.find<AuthController>();
  bool isPasswordVisible = false;
  bool termsPolicy = false;

  // Controllers
  TextEditingController nameController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  Timer? debounceTimer;
  TextEditingController dobController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController footController = TextEditingController();
  TextEditingController clubController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  void togglePass() {
    setState(() {
      isPasswordVisible = !isPasswordVisible;
    });
  }

  void toggleTerms() {
    setState(() {
      termsPolicy = !termsPolicy;
    });
  }

  bool _validatePassword(String password) {
    final hasMinLength = password.length >= 8;
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasSymbol = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    return hasMinLength && hasUpper && hasSymbol;
  }

  void checkUsername() {
    final username = usernameController.text.trim();
    authController.checkUsername(username);
  }

  @override
  void initState() {
    super.initState();
  }

  Map<String, dynamic> body() {
    int? height = int.tryParse(
      heightController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );
    int? weight = int.tryParse(
      weightController.text.replaceAll(RegExp(r'[^0-9]'), ''),
    );

    return {
      "name": nameController.text.trim(),
      "username": usernameController.text.trim(),
      "email": emailController.text.trim(),
      "password": passwordController.text.trim(),
      "role": "player",
      "country": selectedCountry,
      "state": selectedState,
      "dob": dobController.text,
      "number": contactController.text,
      "position": positionController.text,
      "preferredFoot": footController.text.toLowerCase(),
      "currentClub": clubController.text,
      "height": height ?? 0, // default to 0 if parsing fails
      "weight": weight ?? 0, // default to 0 if parsing fails
      "bio": bioController.text,
    };
  }

  /// Date Picker for DOB
  Future<void> _pickDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder:
          (context, child) =>
          Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.light(primary: AppColors.primary),
            ),
            child: child!,
          ),
    );
    if (pickedDate != null) {
      dobController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  /// Bottom modal picker
  void _showBottomPicker({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) =>
          _buildBottomPicker(
            title: title,
            options: options,
            onSelected: (value) {
              onSelected(value);
              Navigator.pop(context);
            },
          ),
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
          color:
          value.isEmpty
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
      child: SingleChildScrollView(
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
                  (option) =>
                  ListTile(
                    title: Text(option),
                    onTap: () => onSelected(option),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
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
                          SizedBox(height: Dimensions.height10),
                          Text(
                            'PLAYER PROFILE SETUP',
                            style: TextStyle(
                              fontFamily: 'BebasNeue',
                              fontSize: Dimensions.font30 * 1.2,
                              color: AppColors.white,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // FORM BODY
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimensions.width20,
                  vertical: Dimensions.height20,
                ),
                child: Column(
                  children: [
                    CustomTextField(
                      hintText: 'Full Name *',
                      controller: nameController,
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      hintText: 'Username *',
                      controller: usernameController,
                      onChanged: (value) {
                        if (value
                            .trim()
                            .isNotEmpty) {
                          debounceTimer?.cancel();
                          debounceTimer = Timer(
                            const Duration(milliseconds: 600),
                                () {
                              checkUsername();
                            },
                          );
                        }
                      },
                      suffixIcon: Obx(() {
                        if (authController.isCheckingUsername.value) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width10,
                              vertical: Dimensions.height10,
                            ),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                              strokeWidth: 4,
                            ),
                          );
                        } else if (authController.usernameMessage.isNotEmpty) {
                          return Icon(
                            authController.isUsernameAvailable.value
                                ? Icons.check_circle
                                : Icons.error,
                            color:
                            authController.isUsernameAvailable.value
                                ? Colors.green
                                : Colors.red,
                            size: Dimensions.iconSize16,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ),
                    SizedBox(height: Dimensions.height5),
                    Obx(
                          () =>
                      authController.usernameMessage.value.isNotEmpty
                          ? Text(
                        authController.usernameMessage.value,
                        style: TextStyle(
                          color:
                          authController.isUsernameAvailable.value
                              ? Colors.green
                              : Colors.red,
                          fontSize: Dimensions.font12,
                        ),
                      )
                          : const SizedBox.shrink(),
                    ),
                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: "Date of Birth (YYYY-MM-DD) *",
                          controller: dobController,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      labelText: "Contact Number *",
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap:
                          () =>
                          _showBottomPicker(
                            title: "Select Playing Position ",
                            options: [
                              'GK', // Goalkeeper
                              'RB', // Right Back
                              'LB', // Left Back
                              'CB', // Center Back
                              'CDM', // Defensive Midfield
                              'CM', // Central Midfield
                              'CAM', // Attacking Midfield
                              'RW', // Right Wing
                              'LW', // Left Wing
                              'ST', //
                            ],
                            onSelected: (val) {
                              setState(() {
                                positionController.text = val;
                              });
                            },
                          ),
                      child: _buildPickerContainer(
                        title: "Playing Position *",
                        value: positionController.text,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap:
                          () =>
                          _showBottomPicker(
                            title: "Preferred Foot",
                            options: ['Left', 'Right', 'Both'],
                            onSelected: (val) {
                              setState(() {
                                footController.text = val;
                              });
                            },
                          ),
                      child: _buildPickerContainer(
                        title: "Preferred Foot *",
                        value: footController.text,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      labelText: "Current Club Name / Free Agent",
                      controller: clubController,
                    ),
                    SizedBox(height: Dimensions.height20),

                    Row(
                      children: [

                        Expanded(
                          child: CustomTextField(
                            hintText: 'Height in ft',
                            controller: heightController,
                            keyboardType: TextInputType.numberWithOptions(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: CustomTextField(hintText: 'Weight in Kg',
                            controller: weightController,
                            keyboardType: TextInputType.numberWithOptions(),),
                        ),
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
                      controller: bioController,
                      maxLines: 4,
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      hintText: 'Email Address *',
                      controller: emailController,
                      autofillHints: [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                    ),

                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      hintText: 'Password',
                      maxLines: 1,
                      controller: passwordController,
                      obscureText: isPasswordVisible,
                      suffixIcon: InkWell(
                        onTap: () {
                          togglePass();
                          print(isPasswordVisible);
                        },
                        child: Icon(
                          !isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
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
                    InkWell(
                      onTap: () {
                        toggleTerms();
                        print(termsPolicy);
                      },
                      child: Row(
                        children: [
                          Icon(
                            termsPolicy
                                ? Icons.check_box_outlined
                                : Icons.check_box_outline_blank,
                            color: AppColors.grey5,
                          ),
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
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomButton(
                      text: "Submit Player Profile",
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          authController.registerOthers(body());
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
