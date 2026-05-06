import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:get/get.dart';
import '../../../controllers/auth_controller.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../utils/dimensions.dart';
import '../../../widgets/custom_appbar.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_textfield.dart';
import '../../../widgets/snackbars.dart';


class ClubProfileForm extends StatefulWidget {
  const ClubProfileForm({Key? key}) : super(key: key);

  @override
  State<ClubProfileForm> createState() => _ClubProfileFormState();
}

class _ClubProfileFormState extends State<ClubProfileForm> {
  final formKey = GlobalKey<FormState>();

  String? selectedClubType;
  bool isPasswordVisible = false;
  bool termsPolicy = false;
  Timer? debounceTimer;

  AuthController authController = Get.find<AuthController>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController clubNameController = TextEditingController();

  final List<Map<String, String>> clubTypeOptions = [
    {"title": "Professional Club", "image": "pro-club"},
    {"title": "Semi-Pro Club", "image": "semi-pro-club"},
    {"title": "Amateur Club", "image": "amateur-club"},
    {"title": "Academy", "image": "acad-club"},
    {"title": "College Team", "image": "coll-club"},
    {"title": "Youth Club", "image": "youth-club"},

  ];

  @override
  void dispose() {
    debounceTimer?.cancel();
    nameController.dispose();
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
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
    "username": clubNameController.text.trim().toLowerCase(),
    "email": emailController.text.trim(),
    "password": passwordController.text,
    "role": "club",
    "clubName": clubNameController.text.trim(),
    "clubType": selectedClubType?.toLowerCase(),
  };

  void _openFullScreenClubPicker() {
    FocusScope.of(context).unfocus();

    Get.to(
          () => Scaffold(
        appBar: CustomAppbar(
          title: 'Select Club Type',
          titleColor: AppColors.textColor,
          subtitle: 'Follow players and manage your club',
          backgroundColor: const Color(0xFF030A1B),
          leadingIcon: const BackButton(color: Colors.white),
        ),
        body: ListView.builder(
          padding: EdgeInsets.all(Dimensions.width20),
          itemCount: clubTypeOptions.length,
          itemBuilder: (context, index) {
            final item = clubTypeOptions[index];
            final isSelected = selectedClubType == item['title'];

            return GestureDetector(
              onTap: () {
                setState(() => selectedClubType = item['title']);
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
                      height: Dimensions.iconSize30*0.8,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppbar(
        backgroundColor: const Color(0xFF030A1B),
        leadingIcon: BackButton(color: AppColors.white),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                AppConstants.getPngAsset('logo3'),
                height: Dimensions.height70,
              ),
              SizedBox(height: Dimensions.height20),

              Text(
                'Create your team account',
                style: TextStyle(
                  fontSize: Dimensions.font23,
                  color: AppColors.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: Dimensions.height5),

              Text(
                'Follow players and manage your club',
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
                      labelText: "Club Name",
                      controller: clubNameController,
                      prefixIcon: CupertinoIcons.person_circle_fill,
                      autofillHints: const [AutofillHints.name],
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

                    // --- FULL SCREEN PICKER TRIGGER ---
                    GestureDetector(
                      onTap: _openFullScreenClubPicker,
                      child: _buildPickerContainer(
                        title: "Club Type",
                        value: selectedClubType ?? '',
                        image: 'jersey',
                      ),
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
                            'I am 13 years or older',
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
                      backgroundColor: AppColors.buttonColor,
                      onPressed: () {
                        if (!termsPolicy) {
                          CustomSnackBar.failure(message: 'You must confirm you are 13 or older.');
                          return;
                        }
                        if (selectedClubType == null) {
                          CustomSnackBar.failure(message: 'Please select a Club Type.');
                          return;
                        }
                        if (formKey.currentState!.validate()) {
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
}

/*  Widget _buildYearPicker() {
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
  }*/

//USERNAME
/*CustomTextField(
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
                    SizedBox(height: Dimensions.height20),*/

/*SizedBox(height: Dimensions.height20),
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
                   */

/*SizedBox(height: Dimensions.height20),
                    CustomTextField(
                      labelText: "Add Bio",
                      maxLines: 3,
                      controller: bioController,
                    ),
                    SizedBox(height: Dimensions.height30),*/
