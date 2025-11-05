import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_client.dart';

class AppRepo {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;

  AppRepo({required this.apiClient, required this.sharedPreferences});
}