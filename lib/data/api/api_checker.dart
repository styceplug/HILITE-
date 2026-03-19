import 'package:get/get.dart';

import '../../routes/routes.dart';
import '../../widgets/snackbars.dart';


class ApiChecker {
  static void checkApi(Response response) {
    print('🧩 ApiChecker triggered → Status: ${response.statusCode}');

    if (response.statusCode == 401) {
      print('🚫 Unauthorized — redirecting to onboarding');
      // CustomSnackBar.failure(message: 'Session expired. Please sign in again.');
      // Get.offAllNamed(AppRoutes.onboardingScreen);
    } else if (response.statusCode == 403) {
      print('🔒 Forbidden request');
      CustomSnackBar.failure(message: 'You don’t have permission for this action.');
    } else if (response.statusCode == 404) {
      print('❓ Resource not found');
      CustomSnackBar.failure(message: 'Resource not found.');
    } else if (response.statusCode == 408 || response.statusCode == 504) {
      print('⏱ Request timed out');
      CustomSnackBar.failure(message: 'Request timed out. Please try again.');
    } else if (response.statusCode == 500) {
      print('💥 Server error');
      CustomSnackBar.failure(message: 'Internet error. Please try again later.');
    } else if (response.statusCode == 0 || response.statusCode == 1) {
      print('📡 No internet / unknown error');
      CustomSnackBar.failure(message: 'No internet connection. Please reconnect.');
    } else if (response.body is Map && response.body['code'] == '99') {
      print('❌ App-level error: ${response.body['message']}');
      CustomSnackBar.failure(
        message: response.body['message'] ?? 'Something went wrong',
      );
    } else {
      print('✅ Request passed API check.');
    }
  }
}