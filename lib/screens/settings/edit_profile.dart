import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:hilite/widgets/country_state_dropdown.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/utils/dimensions.dart';

import '../../widgets/snackbars.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final formKey = GlobalKey<FormState>();
  final UserController userController = Get.find<UserController>();
  final AuthController authController = Get.find<AuthController>();

  // common
  late TextEditingController nameController;
  late TextEditingController usernameController;
  late TextEditingController numberController;
  late TextEditingController bioController;

  // player
  late TextEditingController positionController; // selected via bottom sheet
  late TextEditingController preferredFootController; // bottom sheet
  late TextEditingController currentClubController; // text input
  late TextEditingController heightController;
  late TextEditingController weightController;

  // agent
  late TextEditingController agencyNameController;
  late TextEditingController registrationIdController;
  late TextEditingController experienceController;

  // club
  late TextEditingController clubNameController;
  late TextEditingController managerController;
  late TextEditingController clubTypeController; // bottom sheet
  late TextEditingController yearFoundedController;

  String? selectedCountry;
  String? selectedState;

  // pick lists
  final List<String> positions = [
    'GK', 'RB', 'LB', 'CB', 'CDM', 'CM', 'CAM', 'RW', 'LW', 'ST'
  ];
  final List<String> feet = ['Left', 'Right', 'Both'];
  final List<String> clubTypes = ['Academy', 'Amateur', 'Professional'];

  @override
  void initState() {
    super.initState();
    final user = userController.user.value;

    // initialize controllers with existing values (if user is null, use empty)
    nameController = TextEditingController(text: user?.name ?? '');
    usernameController = TextEditingController(text: user?.username ?? '');
    numberController = TextEditingController(text: user?.number ?? '');
    bioController = TextEditingController(text: user?.bio ?? '');

    selectedCountry = user?.country;
    selectedState = user?.state;

    positionController = TextEditingController(text: user?.playerDetails?.position ?? '');
    preferredFootController = TextEditingController(text: user?.playerDetails?.preferredFoot ?? '');
    currentClubController = TextEditingController(text: user?.playerDetails?.currentClub ?? '');
    heightController = TextEditingController(text: user?.playerDetails?.height?.toString() ?? '');
    weightController = TextEditingController(text: user?.playerDetails?.weight?.toString() ?? '');

    agencyNameController = TextEditingController(text: user?.agentDetails?.agencyName ?? '');
    registrationIdController = TextEditingController(text: user?.agentDetails?.registrationId ?? '');
    experienceController = TextEditingController(text: user?.agentDetails?.experience ?? '');

    clubNameController = TextEditingController(text: user?.clubDetails?.clubName ?? '');
    managerController = TextEditingController(text: user?.clubDetails?.manager ?? '');
    clubTypeController = TextEditingController(text: user?.clubDetails?.clubType ?? '');
    yearFoundedController = TextEditingController(text: user?.clubDetails?.yearFounded ?? '');
  }

  @override
  void dispose() {
    // dispose controllers
    nameController.dispose();
    usernameController.dispose();
    numberController.dispose();
    bioController.dispose();

    positionController.dispose();
    preferredFootController.dispose();
    currentClubController.dispose();
    heightController.dispose();
    weightController.dispose();

    agencyNameController.dispose();
    registrationIdController.dispose();
    experienceController.dispose();

    clubNameController.dispose();
    managerController.dispose();
    clubTypeController.dispose();
    yearFoundedController.dispose();

    super.dispose();
  }

  /// Build a minimal flat body that only includes changed fields.
  Map<String, dynamic> _buildBody() {
    final user = userController.user.value;
    if (user == null) return {};

    final Map<String, dynamic> data = {};

    void addIfChanged(String key, dynamic newValue, dynamic oldValue) {
      final bool isValueEmpty = newValue == null || (newValue is String && newValue.trim().isEmpty);
      if (!isValueEmpty && newValue != oldValue) {
        data[key] = newValue;
      }
    }

    // common
    addIfChanged('name', nameController.text.trim(), user.name);
    addIfChanged('username', usernameController.text.trim(), user.username);
    addIfChanged('number', numberController.text.trim(), user.number);
    addIfChanged('bio', bioController.text.trim(), user.bio);
    addIfChanged('country', selectedCountry, user.country);
    addIfChanged('state', selectedState, user.state);

    // role-specific: player (flat keys)
    if (user.role == 'player') {
      addIfChanged('position', positionController.text.trim(), user.playerDetails?.position);
      addIfChanged('currentClub', currentClubController.text.trim(), user.playerDetails?.currentClub);
      addIfChanged('preferredFoot', preferredFootController.text.trim(), user.playerDetails?.preferredFoot);

      final int? h = int.tryParse(heightController.text.replaceAll(RegExp(r'[^0-9]'), ''));
      final int? w = int.tryParse(weightController.text.replaceAll(RegExp(r'[^0-9]'), ''));

      addIfChanged('height', h, user.playerDetails?.height);
      addIfChanged('weight', w, user.playerDetails?.weight);
    }

    // agent
    if (user.role == 'agent') {
      addIfChanged('agencyName', agencyNameController.text.trim(), user.agentDetails?.agencyName);
      addIfChanged('registrationId', registrationIdController.text.trim(), user.agentDetails?.registrationId);
      addIfChanged('experience', experienceController.text.trim(), user.agentDetails?.experience);
    }

    // club
    if (user.role == 'club') {
      addIfChanged('clubName', clubNameController.text.trim(), user.clubDetails?.clubName);
      addIfChanged('manager', managerController.text.trim(), user.clubDetails?.manager);
      addIfChanged('clubType', clubTypeController.text.trim(), user.clubDetails?.clubType);
      addIfChanged('yearFounded', yearFoundedController.text.trim(), user.clubDetails?.yearFounded);
    }

    return data;
  }

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
          color: value.isEmpty ? AppColors.black.withOpacity(0.5) : AppColors.black,
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
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontFamily: 'BebasNeue', fontSize: Dimensions.font20, color: AppColors.primary)),
            SizedBox(height: Dimensions.height10),
            ...options.map((opt) => ListTile(title: Text(opt), onTap: () => onSelected(opt))).toList(),
            SizedBox(height: Dimensions.height10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Edit Profile'),
      body: Obx(() {
        final user = userController.user.value;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Basic info
                Text('Basic Information', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                SizedBox(height: Dimensions.height10),
                CustomTextField(labelText: 'Full name', controller: nameController),
                SizedBox(height: Dimensions.height10),
                CustomTextField(labelText: 'Username', controller: usernameController),
                SizedBox(height: Dimensions.height10),
                CustomTextField(labelText: 'Bio', controller: bioController, keyboardType: TextInputType.text,maxLines: 3,),
                SizedBox(height: Dimensions.height10),

                // Country/State selector (optional)
                // CountryState(
                //   selectedCountry: selectedCountry,
                //   selectedState: selectedState,
                //   onCountryChanged: (c) => setState(() => selectedCountry = c),
                //   onStateChanged: (s) => setState(() => selectedState = s),
                // ),


                SizedBox(height: Dimensions.height20),

                // Role-specific blocks
                if (user.role == 'player') ...[
                  Text('Player Details', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  SizedBox(height: Dimensions.height10),

                  // position (picker)
                  GestureDetector(
                    onTap: () => _showBottomPicker(title: 'Select Position', options: positions, onSelected: (v) => setState(() => positionController.text = v)),
                    child: _buildPickerContainer(title: 'Position', value: positionController.text),
                  ),
                  SizedBox(height: Dimensions.height10),

                  // current club (text input)
                  CustomTextField(labelText: 'Current club (type name)', controller: currentClubController),
                  SizedBox(height: Dimensions.height10),

                  // preferred foot (picker)
                  GestureDetector(
                    onTap: () => _showBottomPicker(title: 'Preferred foot', options: feet, onSelected: (v) => setState(() => preferredFootController.text = v)),
                    child: _buildPickerContainer(title: 'Preferred foot', value: preferredFootController.text),
                  ),
                  SizedBox(height: Dimensions.height10),

                  // height & weight
                  Row(
                    children: [
                      Expanded(child: CustomTextField(labelText: 'Height (cm)', controller: heightController, keyboardType: TextInputType.number)),
                      SizedBox(width: 10),
                      Expanded(child: CustomTextField(labelText: 'Weight (kg)', controller: weightController, keyboardType: TextInputType.number)),
                    ],
                  ),
                  SizedBox(height: Dimensions.height10),

                  // CustomTextField(labelText: 'Bio / Summary', controller: bioController, maxLines: 3),
                  // SizedBox(height: Dimensions.height20),
                ],

                if (user.role == 'agent') ...[
                  Text('Agent Details', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  SizedBox(height: Dimensions.height10),
                  CustomTextField(labelText: 'Agency name', controller: agencyNameController),
                  SizedBox(height: Dimensions.height10),
                  CustomTextField(labelText: 'Registration ID', controller: registrationIdController),
                  SizedBox(height: Dimensions.height10),
                  CustomTextField(labelText: 'Experience / Summary', controller: experienceController, maxLines: 3),
                  SizedBox(height: Dimensions.height20),
                ],

                if (user.role == 'club') ...[
                  Text('Club Details', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  SizedBox(height: Dimensions.height10),
                  CustomTextField(labelText: 'Club name', controller: clubNameController),
                  SizedBox(height: Dimensions.height10),
                  CustomTextField(labelText: 'Manager', controller: managerController),
                  SizedBox(height: Dimensions.height10),

                  // club type (picker)
                  GestureDetector(
                    onTap: () => _showBottomPicker(title: 'Club type', options: clubTypes, onSelected: (v) => setState(() => clubTypeController.text = v)),
                    child: _buildPickerContainer(title: 'Club type', value: clubTypeController.text),
                  ),
                  SizedBox(height: Dimensions.height10),

                  CustomTextField(labelText: 'Year founded', controller: yearFoundedController, keyboardType: TextInputType.number),
                  SizedBox(height: Dimensions.height20),
                ],

                // For all roles show Save button
                CustomButton(
                  text: 'Save changes',
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      final body = _buildBody();
                      if (body.isEmpty) {
                        // nothing changed
                        Get.back();
                        CustomSnackBar.showToast(message: 'No changes to save');
                        return;
                      }
                      authController.updateUserProfile(body);
                    }
                  },
                ),
                SizedBox(height: Dimensions.height30),
              ],
            ),
          ),
        );
      }),
    );
  }
}