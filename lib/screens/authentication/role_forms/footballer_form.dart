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

  // Controllers
  TextEditingController dobController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController positionController = TextEditingController();
  TextEditingController footController = TextEditingController();
  TextEditingController clubController = TextEditingController();
  TextEditingController heightController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController bioController = TextEditingController();

  String savedName = '';
  String savedUsername = '';
  String savedEmail = '';
  String savedPassword = '';

  @override
  void initState() {
    super.initState();
    _loadSavedSignupData();
  }

  Future<void> _loadSavedSignupData() async {
    final info = await StorageHelper.readBasicInfo();
    final password = await StorageHelper.readPassword();

    setState(() {
      savedName = info['name'] ?? '';
      savedUsername = info['username'] ?? '';
      savedEmail = info['email'] ?? '';
      savedPassword = password ?? '';
    });
  }

  Map<String, dynamic> body() {
    int? height = int.tryParse(heightController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    int? weight = int.tryParse(weightController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    return {
      "name": savedName,
      "username": savedUsername,
      "email": savedEmail,
      "password": savedPassword,
      "role": "player",
      "country": selectedCountry,
      "state": selectedState,
      "dob": dobController.text,
      "number": contactController.text,
      "position": positionController.text,
      "preferredFoot": footController.text.toLowerCase(),
      "currentClub": clubController.text,
      "height": height ?? 0,  // default to 0 if parsing fails
      "weight": weight ?? 0,  // default to 0 if parsing fails
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
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(
            primary: AppColors.primary,
          ),
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
      builder: (context) => _buildBottomPicker(
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
                  (option) => ListTile(
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
                          Text('HILITE',
                              style: TextStyle(
                                fontFamily: 'BebasNeue',
                                fontSize: Dimensions.font30,
                                color: AppColors.white,
                              )),
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
                    GestureDetector(
                      onTap: _pickDate,
                      child: AbsorbPointer(
                        child: CustomTextField(
                          labelText: "Date of Birth (YYYY-MM-DD)",
                          controller: dobController,
                        ),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    CustomTextField(
                      labelText: "Contact Number",
                      controller: contactController,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap: () => _showBottomPicker(
                        title: "Select Playing Position",
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
                        title: "Playing Position",
                        value: positionController.text,
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),

                    GestureDetector(
                      onTap: () => _showBottomPicker(
                        title: "Preferred Foot",
                        options: ['Left', 'Right', 'Both'],
                        onSelected: (val) {
                          setState(() {
                            footController.text = val;
                          });
                        },
                      ),
                      child: _buildPickerContainer(
                        title: "Preferred Foot",
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
                          child: GestureDetector(
                            onTap: () => _showBottomPicker(
                              title: "Select Height",
                              options: [
                                '160 cm',
                                '165 cm',
                                '170 cm',
                                '175 cm',
                                '180 cm',
                                '185 cm',
                                '190 cm',
                                '200 cm',
                                '210 cm',
                                '< 220 cm',
                              ],
                              onSelected: (val) {
                                setState(() {
                                  heightController.text = val;
                                });
                              },
                            ),
                            child: _buildPickerContainer(
                              title: "Height (cm / ft)",
                              value: heightController.text,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _showBottomPicker(
                              title: "Select Weight",
                              options: [
                                '60 kg',
                                '65 kg',
                                '70 kg',
                                '75 kg',
                                '80 kg',
                                '85 kg',
                                '90 kg',
                                '120 lbs',
                                '150 lbs',
                              ],
                              onSelected: (val) {
                                setState(() {
                                  weightController.text = val;
                                });
                              },
                            ),
                            child: _buildPickerContainer(
                              title: "Weight (kg / lbs)",
                              value: weightController.text,
                            ),
                          ),
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