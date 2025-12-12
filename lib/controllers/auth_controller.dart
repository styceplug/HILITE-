import 'package:get/get.dart';
import 'package:hilite/controllers/app_controller.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/data/repo/auth_repo.dart';
import 'package:hilite/data/repo/user_repo.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../utils/app_constants.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final SharedPreferences sharedPreferences;

  AuthController({required this.authRepo, required this.sharedPreferences});

  bool _isLoading = false;

  bool get isLoading => _isLoading;
  var isCheckingUsername = false.obs;
  var isUsernameAvailable = false.obs;
  var usernameMessage = ''.obs;
  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  UserController userController = Get.find<UserController>();
  late AppController appController = Get.find<AppController>();
  Rx<UserModel?> user = Rx<UserModel?>(null);
  UserRepo? userRepo;

  Future<void> login(
    String input,
    String password, {
    bool staySignedIn = false,
  }) async {
    loader.showLoader();
    update();

    try {
      final bool isEmail = input.contains('@') && input.contains('.');

      final Map<String, dynamic> payload = {
        (isEmail ? 'email' : 'username'): input,
        'password': password,
      };

      Response response = await authRepo.apiClient.postData(
        AppConstants.POST_LOGIN,
        payload,
      );
      loader.hideLoader();

      if (response.statusCode == 200) {
        final body = response.body;

        if (body['code'] == '00') {
          final token = body['data'];
          final message = body['message'] ?? 'Login successful';

          if (staySignedIn) {
            await saveUserToken(token);
          }
          await userController.getUserProfile();
          CustomSnackBar.success(
            message:
                '$message: Welcome back ${isEmail ? input.split('@')[0] : input}',
          );
          userController.saveDeviceToken();
          Get.offAllNamed(AppRoutes.homeScreen);
        } else {
          CustomSnackBar.failure(
            message: body['message'] ?? 'Invalid credentials',
          );
        }
      } else {
        CustomSnackBar.failure(
          message: 'Login failed — please try again later',
        );
      }
    } catch (e, s) {
      loader.hideLoader();
      CustomSnackBar.failure(message: 'An error occurred: ${e.toString()}');
      print('$e\n$s');
    }

    update();
  }

  Future<Response> initiatePasswordReset(String email) async {
    loader.showLoader();
    update();
    Response response = await authRepo.initiatePasswordReset(email);
    if (response.statusCode == 200) {
      CustomSnackBar.success(message: 'Password reset link sent to your email');
    } else {
      CustomSnackBar.failure(message: response.body['message']);
    }
    loader.hideLoader();
    update();
    return response;
  }

  Future<void> checkUsername(String username) async {
    if (username.isEmpty) return;

    isCheckingUsername.value = true;
    usernameMessage.value = '';

    try {
      Response response = await authRepo.checkUsername(username);

      if (response.statusCode == 200 && response.body is Map) {
        if (response.body['code'] == '00') {
          isUsernameAvailable.value = true;
          usernameMessage.value =
              response.body['message'] ?? 'Username is available';
        } else {
          isUsernameAvailable.value = false;
          usernameMessage.value =
              response.body['message'] ?? 'Username already taken';
        }
      } else {
        isUsernameAvailable.value = false;
        usernameMessage.value = 'Username already taken';
      }
    } catch (e) {
      isUsernameAvailable.value = false;
      usernameMessage.value = 'Network error. Please retry.';
    } finally {
      isCheckingUsername.value = false;
      update();
    }
  }

  Future<Response> registerFan(Map<String, dynamic> body) async {
    Response response;

    try {
      loader.showLoader();
      update();

      response = await authRepo.registerFan(body);

      if (response.body['code'] == '00' || response.statusCode == 200) {
        CustomSnackBar.success(message: 'Registration Successful');
        userController.saveDeviceToken();
        Get.offAllNamed(AppRoutes.verifyProfileScreen);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Registration Failed',
        );
      }
    } catch (e, s) {
      print('❌ Error in registerFan: $e');
      print('Stacktrace: $s');
      CustomSnackBar.failure(message: 'An error occurred. Please try again.');
      response = Response(statusCode: 500, statusText: e.toString());
    } finally {
      loader.hideLoader();
      update();
    }

    return response;
  }

  Future<void> registerOthers(Map<String, dynamic> body) async {
    loader.showLoader();
    update();

    try {
      Response response = await authRepo.registerOthers(body);

      if (response.statusCode == 201 && response.body['code'] == '00') {
        userController.saveDeviceToken();
        CustomSnackBar.success(
          message: response.body['message'] ?? 'Registration Successful',
        );
        Get.offAllNamed(AppRoutes.verifyProfileScreen);
        final userData = response.body['data'];
      } else if (response.body['code'] == '01') {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Missing required fields',
        );
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Registration failed',
        );
      }
    } catch (e, s) {
      CustomSnackBar.failure(message: 'An error occurred: $e, $s');
      print('$e,$s');
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> saveUserToken(String token) async {
    authRepo.apiClient.token = token;
    authRepo.apiClient.updateHeader(token);
    await authRepo.sharedPreferences.setString(AppConstants.authToken, token);
  }

  Future<bool> loadSavedSession() async {
    final token = authRepo.sharedPreferences.getString(AppConstants.authToken);
    if (token != null && token.isNotEmpty) {
      authRepo.apiClient.updateHeader(token);
      authRepo.apiClient.token = token;
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    loader.showLoader();
    update();

    try {
      await authRepo.sharedPreferences.remove(AppConstants.authToken);
      authRepo.apiClient.updateHeader('');
      authRepo.apiClient.token = '';
      sharedPreferences.remove(AppConstants.authToken);
      userController.clearUserCache();
      appController.changeCurrentAppPage(0);
      CustomSnackBar.success(message: 'Logged out successfully');
      Get.offAllNamed(AppRoutes.onboardingScreen);
    } catch (e) {
      CustomSnackBar.failure(message: 'Logout failed: ${e.toString()}');
      print(e);
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> body) async {
    try {
      loader.showLoader();

      Response response = await authRepo.updateUserProfile(body);

      print('This is body: $body');
      print('Response code: ${response.body['code']}');
      print('Code type: ${response.body['code'].runtimeType}');

      if (response.body['code'].toString() == '00') {
        user.value = UserModel.fromJson(response.body['data']);
        print('${userController.user.value?.bio} at Stage 1');

        if (user.value != null) await userController.saveUser(user.value!);

        print("💾 Cached updated user profile successfully");
        await userController.loadCachedUser();
        print(
          'user from usercontroller ${userController.user.value?.bio} at Stage 2',
        );

        userController.user.refresh();
        print('${userController.user.value?.bio} at Stage 3');

        update();
        Get.back();
        CustomSnackBar.success(message: 'Profile updated successfully');
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e, s) {
      print('🔥 Error updating profile: $e\n$s');
      CustomSnackBar.failure(message: 'An unexpected error occurred');
    } finally {
      loader.hideLoader();
      update();
    }
  }

  bool userLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.authToken);
  }
}
