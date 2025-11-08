import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/auth_controller.dart';

import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../utils/storage_helper.dart';
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
  int? selectedYear;

  String savedName = '';
  String savedUsername = '';
  String savedEmail = '';
  String savedPassword = '';

  AuthController authController = Get.find<AuthController>();

  // Controllers
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController agencyNameController = TextEditingController();
  TextEditingController licenseController = TextEditingController();
  TextEditingController experienceController = TextEditingController();
  TextEditingController clubNameController = TextEditingController();

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

  Map<String, dynamic> agentBody() => {
    "name": savedName,
    "username": savedUsername,
    "email": savedEmail,
    "password": savedPassword,
    "role": "agent",
    "country": selectedCountry,
    "state": selectedState,
    "number": contactNumberController.text,
    "agencyName": agencyNameController.text,
    "registrationId": licenseController.text,
    "experience": experienceController.text,
  };

  Map<String, dynamic> clubBody() => {
    "name": savedName,
    "username": savedUsername,
    "email": savedEmail,
    "password": savedPassword,
    "role": "club",
    "country": selectedCountry,
    "state": selectedState,
    "number": contactNumberController.text,
    "clubName": clubNameController.text,
    "yearFounded": selectedYear ?? 0,
    "clubType": selectedClubType.toLowerCase(),
    "manager": headCoachOrManager,
  };

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
              _buildHeader(),
              Padding(
                padding: EdgeInsets.all(Dimensions.width20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileTypeSelector(),
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

  Widget _buildHeader() {
    return Container(
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
    );
  }

  Widget _buildProfileTypeSelector() {
    return Column(
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
                onTap: () => setState(() => selectedProfileType = 'agent'),
                child: _buildOption(
                  'Scout / Agent',
                  selectedProfileType == 'agent',
                ),
              ),
            ),
            SizedBox(width: Dimensions.width10),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => selectedProfileType = 'club'),
                child: _buildOption(
                  'Football Club',
                  selectedProfileType == 'club',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOption(String text, bool selected) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        border: Border.all(color: AppColors.primary),
        borderRadius: BorderRadius.circular(Dimensions.radius15),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: selected ? AppColors.white : AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAgentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          labelText: "Contact Number",
          controller: contactNumberController,
          keyboardType: TextInputType.phone,
        ),
        SizedBox(height: Dimensions.height20),
        CustomTextField(
          labelText: "Agency Name",
          controller: agencyNameController,
        ),
        SizedBox(height: Dimensions.height20),
        CustomTextField(
          labelText: "License / Registration ID",
          controller: licenseController,
          keyboardType: TextInputType.number,
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
          onStateChanged: (state) => setState(() => selectedState = state),
        ),
        SizedBox(height: Dimensions.height20),
        CustomTextField(
          labelText: "Experience / Players Represented",
          controller: experienceController,
        ),
        SizedBox(height: Dimensions.height30),
        CustomButton(
          text: "Submit Agent Profile",
          onPressed: () {
            if (formKey.currentState!.validate()) {
              authController.registerOthers(agentBody());
              print(agentBody());
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
        CustomTextField(labelText: "Club Name", controller: clubNameController),
        SizedBox(height: Dimensions.height20),
        CustomTextField(
          labelText: "Contact Number",
          controller: contactNumberController,
          keyboardType: TextInputType.phone,
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
          onStateChanged: (state) => setState(() => selectedState = state),
        ),
        SizedBox(height: Dimensions.height20),
        _buildBottomPickerField(
          title: "Head Coach / Manager",
          value: headCoachOrManager,
          options: ["Head Coach", "Manager"],
          onSelected: (value) => setState(() => headCoachOrManager = value),
        ),
        SizedBox(height: Dimensions.height20),
        _buildBottomPickerField(
          title: "Club Type (Academy / Amateur / Professional)",
          value: selectedClubType,
          options: ["Academy", "Amateur", "Professional"],
          onSelected: (value) => setState(() => selectedClubType = value),
        ),
        SizedBox(height: Dimensions.height20),
        _buildYearPicker(),
        SizedBox(height: Dimensions.height30),
        CustomButton(
          text: "Submit Club Profile",
          onPressed: () {
            if (formKey.currentState!.validate()) {
              authController.registerOthers(clubBody());
              print(clubBody());
            }
          },
        ),
        SizedBox(height: Dimensions.height50),
      ],
    );
  }

  Widget _buildBottomPickerField({
    required String title,
    required String value,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    return InkWell(
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
              title: title,
              options: options,
              onSelected: (val) {
                onSelected(val);
                Navigator.pop(context);
              },
            );
          },
        );
      },
      child: _buildPickerContainer(title: title, value: value),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(
      200,
      (index) => currentYear - index,
    ); // last 200 years

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(Dimensions.radius20),
            ),
          ),
          builder: (_) {
            return Container(
              height: Dimensions.screenHeight / 2,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(Dimensions.width20),
                    child: Text(
                      'Select Year Founded',
                      style: TextStyle(
                        fontSize: Dimensions.font18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: years.length,
                      itemBuilder: (context, index) {
                        final year = years[index];
                        return ListTile(
                          title: Text(year.toString()),
                          onTap: () {
                            setState(() {
                              selectedYear = year;
                            });
                            Navigator.pop(context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: _buildPickerContainer(
        title: "Year Founded",
        value: selectedYear != null ? selectedYear.toString() : '',
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
                ListTile(title: Text(option), onTap: () => onSelected(option)),
          ),
        ],
      ),
    );
  }
}
