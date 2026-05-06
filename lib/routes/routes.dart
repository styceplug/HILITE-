import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/screens/authentication/create_account_screen.dart';
import 'package:hilite/screens/authentication/forgot_password.dart';
import 'package:hilite/screens/authentication/login_screen.dart';
import 'package:hilite/screens/authentication/role_forms/footballer_form.dart';
import 'package:hilite/screens/authentication/role_forms/scout_club_form.dart';
import 'package:hilite/screens/authentication/role_forms/team_form.dart';
import 'package:hilite/screens/authentication/select_category_screen.dart';
import 'package:hilite/screens/authentication/verify_profile.dart';
import 'package:hilite/screens/home/home_screen.dart';
import 'package:hilite/screens/others/bookmarks_screen.dart';
import 'package:hilite/screens/others/competition_details_screen.dart';
import 'package:hilite/screens/others/competitions_screen.dart';
import 'package:hilite/screens/others/create_competition_screen.dart';
import 'package:hilite/screens/others/my_competitions_screen.dart' hide CompetitionDetailsScreen;
import 'package:hilite/screens/others/notification_screen.dart';
import 'package:hilite/screens/others/others_profile.dart';
import 'package:hilite/screens/others/recommended_accounts.dart';
import 'package:hilite/screens/others/trials_screen.dart';
import 'package:hilite/screens/posting/post_detail_screen.dart';
import 'package:hilite/screens/posting/upload_content.dart';
import 'package:hilite/screens/settings/edit_profile.dart';
import 'package:hilite/screens/settings/referral_screen.dart';
import 'package:hilite/screens/settings/settings_screen.dart';
import 'package:hilite/screens/settings/wallet_screen.dart';
import 'package:hilite/screens/splash/no_internet_screen.dart';
import 'package:hilite/screens/splash/onboarding_screen.dart';
import 'package:hilite/screens/splash/update_app_screen.dart';
import 'package:hilite/screens/trials/my_trials_screen.dart';
import 'package:hilite/screens/trials/trials_screen_list.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:hilite/widgets/reels_video_item.dart';

import '../controllers/post_controller.dart';
import '../models/message_model.dart';
import '../models/post_model.dart';
import '../screens/home/pages/activities_screen.dart';
import '../screens/messaging/chat_list_screen.dart';
import '../screens/messaging/messaging_screen.dart';
import '../screens/splash/splash.dart';
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

  static const String videoReelScreen = '/video-reel-screen';

  //forms
  static const String footballerForm = '/footballer-form';
  static const String agentForm = '/agent-form';
  static const String clubForm = '/club-form';
  static const String fanForm = '/fan-form';

  //inapp
  static const String homeScreen = '/home-screen';
  static const String othersProfileScreen = '/others-profile-screen';
  static const String settingsScreen = '/settings-screen';
  static const String uploadContent = '/upload-content';
  static const String referralScreen = '/referral-screen';
  static const String postDetailScreen = '/post-detail-screen';
  static const String bookmarksScreen = '/bookmarks-screen';
  static const String recommendedAccountsScreen =
      '/recommended-accounts-screen';

  static const String competitionsScreen = '/competitions-screen';
  static const String walletScreen = '/wallet-screen';
  static const String notificationsScreen = '/notifications-screen';
  static const String trialsScreen = '/trials-screen';
  static const String competitionDetailsScreen = '/competition-details-screen';
  static const String createCompetitionScreen = '/create-competition-screen';
  static const String messagingScreen = '/messaging-screen';
  static const String chatListScreen = '/chat-list-screen';

  //trials
  static const String createTrialScreen = '/create-trial-screen';
  static const String trialDetailScreen = '/trial-detail-screen';
  static const String trialListScreen = '/trial-list-screen';
  static const String myTrialsScreen = '/my-trial-screen';
  static const String myCompetitionsScreen = '/my-competitions-screen';

  static final routes = [
    GetPage(
      name: videoReelScreen,
      page: () {
        // Get the post from arguments
        final PostModel post = Get.arguments as PostModel;

        // Get or create the controller
        final PostController controller = Get.find<PostController>();

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: CustomAppbar(
            backgroundColor: Colors.transparent,
            leadingIcon: BackButton(
              onPressed: () {
                Get.offAllNamed(AppRoutes.homeScreen);
              },
            ),
          ),
          body: ReelsVideoItem(
            index: 0, // Single video, so index is always 0
            post: post,
            controller: controller,
          ),
        );
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: walletScreen,
      page: () {
        return const WalletScreen();
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: bookmarksScreen,
      page: () {
        return const BookmarksScreen();
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: createCompetitionScreen,
      page: () {
        return const CreateCompetitionScreen();
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: myCompetitionsScreen,
      page: () {
        return const MyCompetitionsScreen();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: myTrialsScreen,
      page: () {
        return const MyTrialsScreen();
      },
      transition: Transition.fadeIn,
    ),

    GetPage(
      name: messagingScreen,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final userController = Get.find<UserController>();
        final chat = args?['chat'] as Chat?;

        if (chat == null) {
          return const Scaffold(
            body: Center(
              child: Text('Chat not found'),
            ),
          );
        }

        return MessagingScreen(
          myId: userController.user.value!.id,
          chat: chat,
        );
      },
      transition: Transition.fadeIn,
    ),



    GetPage(
      name: AppRoutes.chatListScreen,
      page: () {
        final userController = Get.find<UserController>();

        return ChatListScreen(
          myId: userController.user.value!.id,
          onChatTap: (chat) {
            Get.toNamed(
              AppRoutes.messagingScreen,
              arguments: {
                'chat': chat,
              },
            );
          },
        );
      },
      transition: Transition.fadeIn,
    ),

    //general

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
      name: agentForm,
      page: () {
        return const AgentProfileForm();
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: clubForm,
      page: () {
        return const ClubProfileForm();
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
      page: () => TrialDetailScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: trialListScreen,
      page: () => TrialListScreen(),
      transition: Transition.fadeIn,
    ),
  ];
}
