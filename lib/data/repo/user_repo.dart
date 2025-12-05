import 'dart:convert';

import 'package:get/get.dart';
import 'package:hilite/data/repo/auth_repo.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart' hide Response;
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/api/api_client.dart';
import '../../utils/app_constants.dart';

class UserRepo {
  final ApiClient apiClient;
  AuthRepo authRepo;
  final SharedPreferences sharedPreferences;

  UserRepo({required this.apiClient, required this.sharedPreferences,required this.authRepo});


  static const String USER_KEY = "user_data";

  Future<Response> getExternalUserPosts(String targetId, String type) async {
    return await apiClient.getData(
      '/v1/user/external/$targetId/posts?type=$type',
    );
  }

  Future<Response> getPersonalPosts(String type) async {
    return await apiClient.getData('${AppConstants.GET_MY_POSTS}?type=$type');
  }

  Future<void> savePostsToCache(String type, List<dynamic> data) async {
    String key = '${AppConstants.GET_MY_POSTS}_$type';
    await sharedPreferences.setString(key, jsonEncode(data));
  }

  List<dynamic> getCachedPosts(String type) {
    String key = '${AppConstants.GET_MY_POSTS}_$type';
    String? jsonString = sharedPreferences.getString(key);

    if (jsonString != null && jsonString.isNotEmpty) {
      return jsonDecode(jsonString);
    }
    return [];
  }

  Future<Response> getUserProfile() async {
    try {
      return await apiClient.getData(AppConstants.GET_PROFILE);
    } catch (e) {
      print('🔥 API Error: $e');
      return Response(statusCode: 500, body: {'code': '99', 'message': 'Network error'});
    }
  }

  Future<void> cacheUserData(Map<String, dynamic> userData) async {
    await sharedPreferences.setString(USER_KEY, jsonEncode(userData));
  }

  Map<String, dynamic>? getCachedUserData() {
    final jsonString = sharedPreferences.getString(USER_KEY);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  Future<void> clearCachedUser() async {
    await sharedPreferences.remove(USER_KEY);
  }

  Future<Response> uploadProfileImage(XFile imageFile) async {
    var request = http.MultipartRequest(
      'PUT',
      Uri.parse('${AppConstants.BASE_URL}${AppConstants.UPDATE_PROFILE_IMAGE}'),
    );


    String? token = authRepo.apiClient.token;
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Add image file
    request.files.add(
      await http.MultipartFile.fromPath(
        'avatar',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ),
    );

    // Send request
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    return Response(
      body: jsonDecode(response.body),
      statusCode: response.statusCode,
    );
  }

  Future<Response> getRecommendedUsers({int limit = 20}) async {
    return await apiClient.getData(
      '${AppConstants.GET_RECOMMENDED_ACCOUNTS}?limit=$limit',
    );
  }

  Future<Response> followUser(String targetId) async {
    return await apiClient.putData(AppConstants.FOLLOW_ACCOUNT(targetId),{});
  }

  Future<Response> unfollowUser(String targetId) async {
    return await apiClient.putData(AppConstants.UNFOLLOW_ACCOUNT(targetId),{});
  }

  Future<Response> blockUser(String targetId) async {
    return await apiClient.putData(AppConstants.BLOCK_ACCOUNT(targetId), {});
  }

  Future<Response> getOthersProfile(String targetId) async {
    return await apiClient.getData(AppConstants.GET_OTHERS_PROFILE(targetId));
  }
}