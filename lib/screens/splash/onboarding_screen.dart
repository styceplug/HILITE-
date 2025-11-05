import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  final List<String> onboardTitles = ['Videos', 'Highlights', 'Reels'];

  final List<String> onboardSubtitles = [
    'Watch and share the best short footballing videos from millions of creators.',
    'Upload the highlights of your best footballing moments',
    'Engage and connect with exciting creators in Africa’s best footballing community.',
  ];

  final List<List<Color>> backgroundGradients = [
    [const Color(0xffE5AFAF), const Color(0xffF5DCDC)],
    [const Color(0xffC4BCFF), const Color(0xffE4E1FF)],
    [const Color(0xffC2D8BE), const Color(0xffE4F1DF)],
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
                        children: [

                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: Dimensions.width30,
                            ),
                            child: Stack(
                              children: [
                                Text(
                                  onboardSubtitles[index],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: Dimensions.font10 * 3,
                                    fontWeight: FontWeight.w600,
                                    foreground:
                                        Paint()
                                          ..style = PaintingStyle.stroke
                                          ..strokeWidth = 2
                                          ..color = Colors.black.withOpacity(0.7),
                                  ),
                                ),
                                Text(
                                  onboardSubtitles[index],
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: Dimensions.font10 * 3,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
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
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                                    ? Dimensions.width25
                                    : Dimensions.width10,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: AppColors.black,width: 0.5),
                              borderRadius: BorderRadius.circular(
                                Dimensions.radius10,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: Dimensions.height30),
                      GestureDetector(
                        onTap: _nextPage,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              height: Dimensions.height10 * 8,
                              width: Dimensions.height10 * 8,
                              child: CircularProgressIndicator(
                                value: (_currentPage + 1) / onboardImages.length,
                                strokeWidth: 3,
                                color: AppColors.white,
                              ),
                            ),
                            Container(
                              height: Dimensions.height65,
                              width: Dimensions.height65,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Iconsax.arrow_right_3,
                                size: Dimensions.iconSize24,
                                color: AppColors.black,
                              ),
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
