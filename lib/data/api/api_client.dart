import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../../utils/app_constants.dart';
import '../../widgets/snackbars.dart';
import 'api_checker.dart';



class ApiClient extends GetConnect implements GetxService {
  late String token;
  final String appBaseUrl;
  late SharedPreferences sharedPreferences;

  late Map<String, String> _mainHeaders;

  ApiClient({required this.appBaseUrl, required this.sharedPreferences}) {
    baseUrl = appBaseUrl;
    timeout = const Duration(seconds: 30);
    token = sharedPreferences.getString(AppConstants.authToken) ?? "";

    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void updateHeader(String token) {
    _mainHeaders = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };
    sharedPreferences.setString(AppConstants.authToken, token);
    if (kDebugMode) print('🔑 Header updated with token: $token');
  }

  /// Check connectivity before making requests
  Future<bool> _hasConnection() async {
    final connectivity = await Connectivity().checkConnectivity();
    final connected = connectivity != ConnectivityResult.none;
    if (!connected) print('📴 No internet connection');
    return connected;
  }

  /// Core request handler (adds loader + toasts + ApiChecker)
  Future<Response> _handleRequest(
      Future<Response> Function() request,
      String uri,
      ) async {
    final loader = GlobalLoaderController(); // Assuming you have a global Loader widget
    try {
      if (!await _hasConnection()) {
        CustomSnackBar.failure(message: 'No internet connection');
        return Response(statusCode: 0, statusText: 'No connection');
      }

      print('\n⚙️ Starting request → $uri');
      loader.showLoader();

      final response = await request().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱ Timeout for $uri');
          CustomSnackBar.failure(message: 'Request timed out. Try again.');
          return Response(statusCode: 408, statusText: 'Timeout');
        },
      );

      loader.hideLoader();

      print('📩 Response for $uri: ${response.statusCode}');
      if (kDebugMode) {
        final size = utf8.encode(response.body.toString()).length;
        print('📦 Body size: ${(size / 1024).toStringAsFixed(2)} KB');
        print('📤 Body: ${response.body}');
      }

      ApiChecker.checkApi(response);
      return response;
    } catch (e, s) {
      loader.hideLoader();
      print('🔥 Error during $uri → $e');
      print(s);
      CustomSnackBar.failure(message: 'Unexpected error. Please try again.');
      return Response(statusCode: 1, statusText: e.toString());
    } finally {
      loader.hideLoader();
    }
  }

  // 📡 GET
  Future<Response> getData(String uri, {Map<String, String>? headers}) async {
    print('➡️ GET: $baseUrl$uri');
    print('📤 Headers: ${headers ?? _mainHeaders}');
    return _handleRequest(
          () => get(uri, headers: headers ?? _mainHeaders),
      uri,
    );
  }

  // 📨 POST
  Future<Response> postData(String uri, dynamic body, {Map<String, String>? headers}) async {
    print('➡️ POST: $baseUrl$uri');
    print('🧾 Body: $body');
    return _handleRequest(
          () => post(uri, body, headers: headers ?? _mainHeaders),
      uri,
    );
  }

  // ✏️ PUT
  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    print('➡️ PUT: $baseUrl$uri');
    print('🧾 Body: $body');
    return _handleRequest(
          () => put(uri, body, headers: headers ?? _mainHeaders),
      uri,
    );
  }

  // 🗑 DELETE
  Future<Response> deleteData(String uri, {Map<String, String>? headers}) async {
    print('➡️ DELETE: $baseUrl$uri');
    return _handleRequest(
          () => delete(uri, headers: headers ?? _mainHeaders),
      uri,
    );
  }

  // 📦 MULTIPART POST (for image uploads)
  Future<Response> postMultipartData(String uri, http.MultipartRequest request) async {
    if (!await _hasConnection()) {
      CustomSnackBar.failure(message: 'No internet connection');
      return Response(statusCode: 0, statusText: 'No connection');
    }

    try {
      print('➡️ MULTIPART POST: $uri');
      request.headers.addAll(_mainHeaders);

      print('📤 Fields: ${request.fields}');
      print('📎 Files: ${request.files.map((f) => f.field).join(', ')}');

      final loader = GlobalLoaderController();
      loader.showLoader();

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 45),
        onTimeout: () {
          loader.hideLoader();
          CustomSnackBar.failure(message: 'Upload timed out. Try again.');
          throw Exception('Timeout during upload');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);
      loader.hideLoader();

      print('📩 Multipart Response Status: ${response.statusCode}');
      print('📩 Multipart Body: ${response.body}');

      final parsedBody = jsonDecode(response.body);
      final result = Response(
        statusCode: response.statusCode,
        body: parsedBody,
        statusText: response.reasonPhrase,
      );

      ApiChecker.checkApi(result);
      return result;
    } catch (e, s) {
      print('🔥 Multipart Error ($uri): $e');
      print(s);
      CustomSnackBar.failure(message: 'Upload failed. Please try again.');
      return Response(statusCode: 1, statusText: e.toString());
    }
  }
}