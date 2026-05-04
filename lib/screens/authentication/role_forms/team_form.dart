import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/country_state_dropdown.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';

class ClubProfileForm extends StatefulWidget {
  const ClubProfileForm({Key? key}) : super(key: key);

  @override
  State<ClubProfileForm> createState() => _ClubProfileFormState();
}

class _ClubProfileFormState extends State<ClubProfileForm> {
  final formKey = GlobalKey<FormState>();

  String? selectedCountry;
  String? selectedState;
  String selectedClubType = '';
  String headCoachOrManager = '';
  int? selectedYear;
  bool isPasswordVisible = false;
  bool termsPolicy = false;
  Timer? debounceTimer;

  AuthController authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController clubNameController = TextEditingController();

  @override
  void dispose() {
    debounceTimer?.cancel();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    bioController.dispose();
    contactNumberController.dispose();
    clubNameController.dispose();
    super.dispose();
  }

  void togglePass() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void toggleTerms() {
    setState(() => termsPolicy = !termsPolicy);
  }

  void checkUsername() {
    final username = usernameController.text.trim();
    authController.checkUsername(username);
  }

  Map<String, dynamic> clubBody() => {
    "name": nameController.text,
    "username": usernameController.text,
    "email": emailController.text,
    "password": passwordController.text,
    "role": "club",
    "country": selectedCountry,
    "state": selectedState,
    "number": contactNumberController.text,
    "clubName": clubNameController.text,
    "yearFounded": selectedYear ?? 0,
    "clubType": selectedClubType.toLowerCase(),
    "manager": headCoachOrManager,
    "bio": bioController.text
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
                    CustomTextField(
                      hintText: 'Pick Username *',
                      controller: usernameController,
                      onChanged: (value) {
                        if (value.trim().isNotEmpty) {
                          debounceTimer?.cancel();
                          debounceTimer = Timer(const Duration(milliseconds: 600), checkUsername);
                        }
                      },
                      suffixIcon: Obx(() {
                        if (authController.isCheckingUsername.value) {
                          return Container(
                            padding: EdgeInsets.all(Dimensions.width10),
                            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 4),
                          );
                        } else if (authController.usernameMessage.isNotEmpty) {
                          return Icon(
                            authController.isUsernameAvailable.value ? Icons.check_circle : Icons.error,
                            color: authController.isUsernameAvailable.value ? Colors.green : Colors.red,
                            size: Dimensions.iconSize16,
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    ),
                    SizedBox(height: Dimensions.height5),
                    Obx(() => authController.usernameMessage.value.isNotEmpty
                        ? Text(
                      authController.usernameMessage.value,
                      style: TextStyle(
                        color: authController.isUsernameAvailable.value ? Colors.green : Colors.red,
                        fontSize: Dimensions.font12,
                      ),
                    )
                        : const SizedBox.shrink()),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      hintText: 'Email Address *',
                      controller: emailController,
                      autofillHints: const [AutofillHints.email],
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      hintText: 'Password',
                      maxLines: 1,
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      suffixIcon: InkWell(
                        onTap: togglePass,
                        child: Icon(!isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      ),
                    ),
                    SizedBox(height: Dimensions.height20),
                    Text(
                      'Password must be at least 8 character long and include 1 capital letter and 1 symbol',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: AppColors.grey5, fontSize: Dimensions.font13),
                    ),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(labelText: "Club Name *", controller: clubNameController),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      labelText: "Contact Number *",
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
                      title: "Head Coach or Manager *",
                      value: headCoachOrManager,
                      options: const ["Head Coach", "Manager"],
                      onSelected: (value) => setState(() => headCoachOrManager = value),
                    ),
                    SizedBox(height: Dimensions.height20),
                    _buildBottomPickerField(
                      title: "Club Type * (Academy or Amateur or Pro.)",
                      value: selectedClubType,
                      options: const ["Academy", "Amateur", "Professional"],
                      onSelected: (value) => setState(() => selectedClubType = value),
                    ),
                    SizedBox(height: Dimensions.height20),
                    _buildYearPicker(),
                    SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      labelText: "Add Bio",
                      maxLines: 3,
                      controller: bioController,
                    ),
                    SizedBox(height: Dimensions.height30),
                    InkWell(
                      onTap: toggleTerms,
                      child: Row(
                        children: [
                          Icon(
                            termsPolicy ? Icons.check_box_outlined : Icons.check_box_outline_blank,
                            color: AppColors.grey5,
                          ),
                          SizedBox(width: Dimensions.width5),
                          Text(
                            'I agree to the Terms and Privacy Policy',
                            style: TextStyle(color: AppColors.grey5, fontSize: Dimensions.font13),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: Dimensions.height30),
                    CustomButton(
                      text: "Submit Club Profile",
                      onPressed: () {
                        if (termsPolicy) {
                          authController.registerOthers(clubBody());
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

  Widget _buildHeader() {
    return Container(
      height: Dimensions.screenHeight / 3.5,
      width: Dimensions.screenWidth,
      color: AppColors.primary,
      child: Stack(
        children: [
          Positioned(
            right: -Dimensions.width100,
            bottom: Dimensions.height20,
            child: Text(
              'CLUB',
              style: TextStyle(
                fontFamily: 'BebasNeue',
                fontSize: Dimensions.font30 * 4,
                color: AppColors.white.withOpacity(0.08),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                  ),
                  const Spacer(),
                  Text(
                    'CLUB PROFILE SETUP',
                    style: TextStyle(
                      fontFamily: 'BebasNeue',
                      fontSize: Dimensions.font30 * 1.2,
                      color: AppColors.white,
                      height: 1.1,
                    ),
                  ),
                  SizedBox(height: Dimensions.height10),
                  Text(
                    'Kindly fill in your football club details below.',
                    style: TextStyle(
                      fontSize: Dimensions.font15,
                      color: AppColors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
          ),
          builder: (_) => _buildBottomPicker(
            title: title,
            options: options,
            onSelected: (val) {
              onSelected(val);
              Navigator.pop(context);
            },
          ),
        );
      },
      child: _buildPickerContainer(title: title, value: value),
    );
  }

  Widget _buildYearPicker() {
    final currentYear = DateTime.now().year;
    final years = List.generate(200, (index) => currentYear - index);

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
          ),
          builder: (_) {
            return SizedBox(
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
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: years.length,
                      itemBuilder: (context, index) {
                        final year = years[index];
                        return ListTile(
                          title: Text(year.toString()),
                          onTap: () {
                            setState(() => selectedYear = year);
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
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width10, vertical: Dimensions.height15),
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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height20),
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
          ...options.map((option) => ListTile(title: Text(option), onTap: () => onSelected(option))),
        ],
      ),
    );
  }
}
