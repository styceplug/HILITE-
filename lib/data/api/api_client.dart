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
  Map<String, String> get mainHeaders => _mainHeaders;

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
    if (!connected) {
      print('📴 No internet connection');
      CustomSnackBar.failure(message: 'No internet connection');
    };
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

      final response = await request();

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
    // print('🧾 Body: $body'); // Optional: Comment out for large files

    // 1. Prepare mutable headers starting with defaults
    Map<String, String> requestHeaders = Map.from(_mainHeaders ?? {});

    // 2. Merge custom headers if provided
    if (headers != null) {
      requestHeaders.addAll(headers);
    }

    // 3. 🚨 CRITICAL FIX: If sending a file (FormData), remove Content-Type.
    // This forces GetConnect to generate the correct 'multipart/form-data; boundary=...' header.
    if (body is FormData) {
      requestHeaders.remove('Content-Type');
    }

    // 4. Execute request with modified headers
    return _handleRequest(
          () => post(uri, body, headers: requestHeaders),
      uri,
    );
  }

  // ✏️ PUT
  Future<Response> putData(String uri, dynamic body, {Map<String, String>? headers}) async {
    print('➡️ PUT: $baseUrl$uri');
    print('🧾 Body: $body');

    // 💡 NEW DIAGNOSTIC PRINT: Show the final headers being used
    final finalHeaders = headers ?? _mainHeaders;
    print('🔍 DEBUG PUT HEADERS: $finalHeaders');

    return _handleRequest(
          () => put(uri, body, headers: finalHeaders),
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

      dynamic parsedBody = {}; // Initialize as empty map/dynamic

// 💡 CRITICAL FIX: Only attempt to decode JSON for success or expected error codes (e.g., 4xx)
      if (response.statusCode < 400 || response.statusCode == 400) {
        try {
          parsedBody = jsonDecode(response.body);
        } catch (e) {
          // If decoding fails (e.g., empty body or invalid JSON), log it but proceed
          print("Warning: Failed to decode JSON body for status ${response.statusCode}.");
          parsedBody = {'error': 'Failed to decode response body'};
        }
      } else {
        // For 500 errors, the body is usually not JSON (HTML/Plain Text)
        // We treat the raw body as the error message content.
        parsedBody = {'error': response.body};
      }

      final result = Response(
        statusCode: response.statusCode,
        body: parsedBody, // Now safely a map/dynamic
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