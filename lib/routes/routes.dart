import 'package:get/get.dart';
import 'package:hilite/screens/authentication/create_account_screen.dart';
import 'package:hilite/screens/authentication/forgot_password.dart';
import 'package:hilite/screens/authentication/login_screen.dart';
import 'package:hilite/screens/authentication/role_forms/footballer_form.dart';
import 'package:hilite/screens/authentication/role_forms/scout_club_form.dart';
import 'package:hilite/screens/authentication/select_category_screen.dart';
import 'package:hilite/screens/authentication/verify_profile.dart';
import 'package:hilite/screens/home/home_screen.dart';
import 'package:hilite/screens/others/competition_details_screen.dart';
import 'package:hilite/screens/others/competitions_screen.dart';
import 'package:hilite/screens/others/notification_screen.dart';
import 'package:hilite/screens/others/others_profile.dart';
import 'package:hilite/screens/others/recommended_accounts.dart';
import 'package:hilite/screens/others/trials_screen.dart';
import 'package:hilite/screens/posting/post_detail_screen.dart';
import 'package:hilite/screens/posting/upload_content.dart';
import 'package:hilite/screens/settings/edit_profile.dart';
import 'package:hilite/screens/settings/referral_screen.dart';
import 'package:hilite/screens/settings/settings_screen.dart';
import 'package:hilite/screens/splash/no_internet_screen.dart';
import 'package:hilite/screens/splash/onboarding_screen.dart';
import 'package:hilite/screens/splash/update_app_screen.dart';
import 'package:hilite/screens/trials/trials_screen_list.dart';

import '../screens/splash/splash.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/trials/create_trails_screen.dart';
import '../screens/trials/trial_details_screen.dart';

class AppRoutes {
  //general
  static const String splashScreen = '/splash-screen';
  static const String splash = '/splash';
  static const String onboardingScreen = '/onboarding-screen';
  static const String updateAppScreen = '/update-app-screen';
  static const String noInternetScreen = '/no-internet-screen';

  //auth
  static const String loginScreen = '/login-screen';
  static const String createAccountScreen = '/create-account-screen';
  static const String selectCategoryScreen = '/select-category-screen';
  static const String forgotPasswordScreen = '/forgot-password-screen';
  static const String verifyProfileScreen = '/verify-profile-screen';
  static const String editProfileScreen = '/edit-profile-screen';

  //forms
  static const String footballerForm = '/footballer-form';
  static const String scoutClubForm = '/scout-club-form';
  static const String fanForm = '/fan-form';

  //inapp
  static const String homeScreen = '/home-screen';
  static const String othersProfileScreen = '/others-profile-screen';
  static const String settingsScreen = '/settings-screen';
  static const String uploadContent = '/upload-content';
  static const String referralScreen = '/referral-screen';
  static const String postDetailScreen = '/post-detail-screen';
  static const String recommendedAccountsScreen =
      '/recommended-accounts-screen';

  static const String competitionsScreen = '/competitions-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String trialsScreen = '/trials-screen';
  static const String competitionDetailsScreen = '/competition-details-screen';

  //trials
  static const String createTrialScreen = '/create-trial-screen';
  static const String trialDetailScreen = '/trial-detail-screen';
  static const String trialListScreen = '/trial-list-screen';

  static final routes = [
    //general
    GetPage(
      name: splashScreen,
      page: () {
        return const SplashScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: splash,
      page: () {
        return const Splash();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: onboardingScreen,
      page: () {
        return const OnboardingScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: updateAppScreen,
      page: () {
        return const UpdateAppScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: noInternetScreen,
      page: () {
        return const NoInternetScreen();
      },
      transition: Transition.fadeIn,
    ),

    //auth
    GetPage(
      name: loginScreen,
      page: () {
        return const LoginScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: createAccountScreen,
      page: () {
        return const CreateAccountScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: selectCategoryScreen,
      page: () {
        return const SelectCategoryScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: forgotPasswordScreen,
      page: () {
        return const ForgotPassword();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: verifyProfileScreen,
      page: () {
        return const VerifyProfile();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: editProfileScreen,
      page: () {
        return const EditProfileScreen();
      },
      transition: Transition.fadeIn,
    ),

    //forms
    GetPage(
      name: footballerForm,
      page: () {
        return const FootballerForm();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: scoutClubForm,
      page: () {
        return const ScoutClubForm();
      },
      transition: Transition.fadeIn,
    ),

    //inapp
    GetPage(
      name: homeScreen,
      page: () {
        return const HomeScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: othersProfileScreen,
      page: () {
        return const OthersProfileScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: settingsScreen,
      page: () {
        return const SettingsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: uploadContent,
      page: () {
        return const UploadContent();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: postDetailScreen,
      page: () => const PostDetailsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: recommendedAccountsScreen,
      page: () => const RecommendedAccountsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: referralScreen,
      page: () => ReferralScreen(),
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: competitionsScreen,
      page: () => CompetitionsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: notificationsScreen,
      page: () => NotificationScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: trialsScreen,
      page: () => TrialsScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: competitionDetailsScreen,
      page: () => CompetitionDetailsScreen(competitionId: ''),
    ),

    //trials
    GetPage(
      name: createTrialScreen,
      page: () => const CreateTrialScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: trialDetailScreen,
      page: () => TrialDetailScreen(trialId: ''),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: trialListScreen,
      page: () => TrialListScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
