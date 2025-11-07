import 'package:get/get.dart';
import 'package:hilite/data/repo/auth_repo.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/routes/routes.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_constants.dart';

class AuthController extends GetxController implements GetxService {
  final AuthRepo authRepo;
  final SharedPreferences sharedPreferences;

  AuthController({required this.authRepo, required this.sharedPreferences});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();


  Future<void> login(String username, String password, {bool staySignedIn = false}) async {
    loader.showLoader();
    update();
    Response response = await authRepo.login(username, password);
    if (response.statusCode == 200) {
      if (staySignedIn) {
        saveUserToken(response.body['token']);
      }
      authRepo.apiClient.updateHeader(response.body['token']);
      Get.offAllNamed(AppRoutes.homeScreen);
      CustomSnackBar.success(
          message: 'Login Successfully: Welcome back ${response.body['username']}');
    } else {
      CustomSnackBar.failure(message: 'Login Failed');
    }
    loader.hideLoader();
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


  Future<Response> registerFan(Map<String, dynamic> body) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerFan(body);
    _isLoading = false;
    update();
    return response;
  }

  Future<Response> registerOthers(Map<String, dynamic> body) async {
    _isLoading = true;
    update();
    Response response = await authRepo.registerOthers(body);
    _isLoading = false;
    update();
    return response;
  }

  Future<Response> checkUsername(String username) async {
    _isLoading = true;
    update();
    Response response = await authRepo.checkUsername(username);
    _isLoading = false;
    update();
    return response;
  }


  void saveUserToken(String token) {
    authRepo.apiClient.token = token;
    authRepo.apiClient.updateHeader(token);
    sharedPreferences.setString(AppConstants.authToken, token);
  }

  bool userLoggedIn() {
    return sharedPreferences.containsKey(AppConstants.authToken);
  }

  void clearSharedData() {
    sharedPreferences.remove(AppConstants.authToken);
    authRepo.apiClient.token = '';
    authRepo.apiClient.updateHeader('');
  }
}
