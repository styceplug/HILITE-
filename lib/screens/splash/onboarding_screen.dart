import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/widgets/custom_button.dart';
import 'package:iconsax/iconsax.dart';

import '../../routes/routes.dart';
import '../../utils/app_constants.dart';
import '../../utils/colors.dart';
import '../../utils/dimensions.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<String> onboardImages = [
    AppConstants.getPngAsset('onboard1'),
    AppConstants.getPngAsset('onboard2'),
    AppConstants.getPngAsset('onboard3'),
  ];

  final List<String> onboardTitles = [
    'Get Seen.\nGet Signed.',
    'Turn Your Highlights\nInto Opportunities',
    'Connect. Grow.\nGet noticed.',
  ];

  final List<String> onboardSubtitles = [
    'Upload your highlights \nGet discovered by scouts.',
    'Upload your clips and let scouts, clubs, and fans discover you.',
    'Join Africa\'s fastest-growing football community.',
  ];

  void _nextPage() {
    if (_currentPage < onboardImages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Get.offAllNamed(AppRoutes.splashScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        top: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage(onboardImages[_currentPage]),
            ),
          ),
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: onboardImages.length,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width30,
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      onboardTitles[index],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Dimensions.font10 * 3.3,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD6D9E0),
                                      ),
                                    ),
                                    SizedBox(height: Dimensions.height10),
                                    Text(
                                      onboardSubtitles[index],
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: Dimensions.font18,
                                        fontFamily: 'Poppins',
                                        color: Color(0xFFD6D9E0),
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    bottom: Dimensions.height100,
                    top: Dimensions.height30,
                    left: Dimensions.width30,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(onboardImages.length, (index) {
                          bool isActive = index == _currentPage;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: EdgeInsets.symmetric(
                              horizontal: Dimensions.width5,
                            ),
                            height: Dimensions.height10,
                            width:
                                isActive
                                    ? Dimensions.width50
                                    : Dimensions.width10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: AppColors.black,
                                width: 0.5,
                              ),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius10,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: Dimensions.height30),
                      Padding(
                        padding: EdgeInsets.only(right: Dimensions.width30),
                        child: _currentPage < onboardImages.length - 1 ? GestureDetector(
                          onTap: _nextPage,
                          child: CustomButton(
                            onPressed: _nextPage,
                            text: 'Continue',
                            backgroundColor: AppColors.buttonColor,
                          ),
                        ) : Column(
                          children: [
                            CustomButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.selectCategoryScreen);
                              },
                              text: 'Get Started',
                              backgroundColor: AppColors.buttonColor,
                            ),
                            SizedBox(height: Dimensions.height15),
                            CustomButton(
                              onPressed: () {
                                Get.toNamed(AppRoutes.loginScreen);
                              },
                              text: 'Login',
                              backgroundColor: AppColors.buttonColor.withOpacity(0.1),
                              borderColor: AppColors.buttonColor.withOpacity(0.4),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
