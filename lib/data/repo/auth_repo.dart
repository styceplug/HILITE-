import 'package:get/get.dart';
import 'package:hilite/data/api/api_client.dart';
import 'package:hilite/utils/app_constants.dart';

class AuthRepo {
  final ApiClient apiClient;

  AuthRepo({required this.apiClient});

  Future<Response> login(String username, String password) async {
    return await apiClient.postData(AppConstants.POST_LOGIN, {"username": username, "password": password});
  }

  Future<Response> registerFan(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.POST_REGISTER_FAN, body);
  }

  Future<Response> registerOthers(Map<String, dynamic> body) async {
    return await apiClient.postData(AppConstants.POST_REGISTER_OTHERS, body);
  }

  Future<Response> checkUsername(String username) async {
    return await apiClient.getData('${AppConstants.GET_USERNAME_AVAILABILITY}/$username');
  }

  Future<Response> initiatePasswordReset(String email) async {
    return await apiClient.postData(AppConstants.POST_PASS_RESET, {"email": email});
  }
}
