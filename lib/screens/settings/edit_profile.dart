
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import '../../controllers/user_controller.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';
import '../../widgets/country_state_dropdown.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_textfield.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();

  // Controllers
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController emailController;
  late TextEditingController numberController;
  late TextEditingController positionController;
  late TextEditingController clubController;
  late TextEditingController heightController;
  late TextEditingController weightController;
  late TextEditingController bioController;

  String? selectedCountry;
  String? selectedState;

  @override
  void initState() {
    super.initState();
    final user = userController.user.value;

    nameController = TextEditingController(text: user?.name ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    numberController = TextEditingController(text: user?.number ?? '');
    positionController = TextEditingController(text: user?.playerDetails?.position ?? '');
    clubController = TextEditingController(text: user?.playerDetails?.currentClub ?? '');
    heightController = TextEditingController(text: '${user?.playerDetails?.height ?? ''}');
    weightController = TextEditingController(text: '${user?.playerDetails?.weight ?? ''}');
    bioController = TextEditingController(text: user?.bio ?? '');
    selectedCountry = user?.country;
    selectedState = user?.state;
  }

  Map<String, dynamic> body() {
    final user = userController.user.value;
    if (user == null) return {};

    Map<String, dynamic> data = {};

    int? height = int.tryParse(heightController.text.replaceAll(RegExp(r'[^0-9]'), ''));
    int? weight = int.tryParse(weightController.text.replaceAll(RegExp(r'[^0-9]'), ''));

    if (nameController.text.trim() != user.name) {
      data["name"] = nameController.text.trim();
    }
    if (usernameController.text.trim() != user.username) {
      data["username"] = usernameController.text.trim();
    }
    if (numberController.text.trim() != user.number) {
      data["number"] = numberController.text.trim();
    }
    if (selectedCountry != user.country) {
      data["country"] = selectedCountry;
    }
    if (selectedState != user.state) {
      data["state"] = selectedState;
    }

    if (positionController.text.trim() != (user.playerDetails?.position ?? '')) {
      data["position"] = positionController.text.trim();
    }
    if (clubController.text.trim() != (user.playerDetails?.currentClub ?? '')) {
      data["currentClub"] = clubController.text.trim();
    }
    if (bioController.text.trim() != (user.bio ?? '')) {
      data["bio"] = bioController.text.trim();
    }
    if (height != user.playerDetails?.height) {
      data["height"] = height ?? 0;
    }
    if (weight != user.playerDetails?.weight) {
      data["weight"] = weight ?? 0;
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Edit Profile'),
      body: Obx(() {
        final user = userController.user.value;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: Dimensions.width20,
            vertical: Dimensions.height20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name Field
                CustomTextField(
                  labelText: "Full Name",
                  controller: nameController,
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  "Can be edited once a year",
                  style: TextStyle(
                    color: AppColors.grey4,
                    fontSize: Dimensions.font12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // Username Field
                CustomTextField(
                  labelText: "Username",
                  controller: usernameController,
                ),
                SizedBox(height: Dimensions.height5),
                Text(
                  "Can be edited once every 3 months",
                  style: TextStyle(
                    color: AppColors.grey4,
                    fontSize: Dimensions.font12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: Dimensions.height20),


                // Contact Number
                CustomTextField(
                  labelText: "Contact Number",
                  controller: numberController,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: Dimensions.height20),

                // Playing Position
                GestureDetector(
                  onTap: () => _showBottomPicker(
                    title: "Select Playing Position",
                    options: [
                      'GK', 'RB', 'LB', 'CB',
                      'CDM', 'CM', 'CAM', 'RW', 'LW', 'ST'
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

                // Club Name
                CustomTextField(
                  labelText: "Current Club / Free Agent",
                  controller: clubController,
                ),
                SizedBox(height: Dimensions.height20),

                // Height & Weight
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
                            '60 kg','65 kg','70 kg','75 kg','80 kg','85 kg',
                            '90 kg','120 lbs','150 lbs',
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

                // Country & State
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

                // Bio
                CustomTextField(
                  labelText: "Player Bio / Description",
                  controller: bioController,
                  maxLines: 4,
                ),
                SizedBox(height: Dimensions.height30),

                CustomButton(
                  text: "Save Changes",
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      authController.updateUserProfile(body());
                    }
                  },
                ),
                SizedBox(height: Dimensions.height50),
              ],
            ),
          ),
        );
      }),
    );
  }

  // Bottom picker (reuse from your other screen)
  void _showBottomPicker({
    required String title,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
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
}