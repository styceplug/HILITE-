import 'dart:async';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/api/api_checker.dart';
import '../data/repo/user_repo.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final SharedPreferences sharedPreferences;

  UserController({required this.userRepo, required this.sharedPreferences});

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  Rx<UserModel?> user = Rx<UserModel?>(null);
  var recommendedUsers = <UserModel>[].obs;
  Rxn<UserModel> othersProfile = Rxn<UserModel>();
  RxList<UserModel> filteredUsers = <UserModel>[].obs;

  bool isPostsLoading = false;
  // List<PersonalPostModel> myPosts = [];





  String currentPostType = 'video';
  Map<String, List<PersonalPostModel>> postCache = {
    'text': [],
    'image': [],
    'video': [],
  };
  bool isFirstLoad = false;
  Map<String, List<PersonalPostModel>> externalPostCache = {
    'text': [],
    'image': [],
    'video': [],
  };
  List<UserModel> _relationshipList = [];
  List<UserModel> get relationshipList => _relationshipList;
  List<UserModel> _filteredRelationshipList = [];
  List<UserModel> get filteredRelationshipList => _filteredRelationshipList;
  bool isExternalPostsLoading = false;
  String currentExternalPostType = 'text';


  RxString searchQuery = ''.obs;
  RxString selectedRole = ''.obs;
  RxString selectedPosition = ''.obs;
  RxString selectedClub = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCachedUser();
  }



  Future<void> getRelationshipUsers(String type, {String? targetId}) async {
    loader.showLoader();
    _relationshipList = [];
    _filteredRelationshipList = [];
    update();

    Response response;

    // 2. Determine which API call to make
    if (targetId != null && targetId.isNotEmpty) {
      // 🅰️ External Profile (Viewing someone else's followers)
      if (type == 'followers') {
        response = await userRepo.getExternalRelationshipAccounts(targetId, followers: true);
      } else {
        response = await userRepo.getExternalRelationshipAccounts(targetId, following: true);
      }
    } else {
      // 🅱️ Personal Profile (Viewing my own followers)
      if (type == 'followers') {
        response = await userRepo.getRelationshipAccounts(followers: true);
      } else if (type == 'following') {
        response = await userRepo.getRelationshipAccounts(following: true);
      } else {
        response = await userRepo.getRelationshipAccounts(blocked: true);
      }
    }

    // 3. Process Response
    if (response.statusCode == 200) {
      List<dynamic> rawList = response.body['data'];
      _relationshipList = rawList.map((e) => UserModel.fromJson(e)).toList();
      _filteredRelationshipList = List.from(_relationshipList); // Init search list
    } else {
      ApiChecker.checkApi(response);
    }

    // 4. Finish
    loader.hideLoader();
    update();
  }

  void searchRelationship(String query) {
    if (query.isEmpty) {
      _filteredRelationshipList = List.from(_relationshipList);
    } else {
      _filteredRelationshipList = _relationshipList.where((user) {
        return user.name.toLowerCase().contains(query.toLowerCase()) ||
            user.username.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    update(); // Update UI
  }

  Future<void> saveDeviceToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      // 1. Request Permission
      NotificationSettings settings = await messaging.requestPermission(
        alert: true, badge: true, sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {

        // 🍎 iOS SPECIFIC FIX: Wait for APNs Token
        if (Platform.isIOS) {
          String? apnsToken = await messaging.getAPNSToken();

          // Retry logic: Wait up to 3 seconds if token is null
          if (apnsToken == null) {
            await Future.delayed(const Duration(seconds: 3));
            apnsToken = await messaging.getAPNSToken();
          }

          // If still null, we are likely on a Simulator or config is wrong
          if (apnsToken == null) {
            print("❌ APNs Token is null. Are you on a Simulator? Push won't work.");
            return; // Stop here to prevent the crash
          }
        }

        // 2. Now it's safe to get the FCM Token
        String? token = await messaging.getToken();

        if (token != null) {
          String platform = Platform.isAndroid ? 'android' : 'ios';
          print("📱 Device Token: $token");

          // 3. Send to Backend
          Response response = await userRepo.updateDeviceToken(token, platform);

          if (response.statusCode == 200) {
            print("✅ Device Token Synced Successfully");
          } else {
            print("⚠️ Failed to sync token: ${response.body}");
          }
        }
      }
    } catch (e) {
      print("❌ Error saving device token: $e");
    }
  }

  void clearExternalCache() {
    externalPostCache = {
      'text': [],
      'image': [],
      'video': [],
    };
    currentExternalPostType = 'text';
    update();
  }

  Future<void> getExternalUserPosts(String targetId, String type) async {
    currentExternalPostType = type;

    // Check if we already fetched this type for this session
    if (externalPostCache[type]!.isNotEmpty) {
      isExternalPostsLoading = false;
      update();
    } else {
      isExternalPostsLoading = true;
      update();
    }

    Response response = await userRepo.getExternalUserPosts(targetId, type);

    if (response.statusCode == 200) {
      List<dynamic> data = response.body['data'];
      // Parse using the same model (since structure is identical)
      externalPostCache[type] = data.map((e) => PersonalPostModel.fromJson(e)).toList();
    } else {
      print("Error fetching external posts: ${response.statusText}");
    }

    isExternalPostsLoading = false;
    update();
  }

  Future<void> saveUser(UserModel userModel) async {
    user.value = userModel;
    await userRepo.cacheUserData(userModel.toJson());
    update();
  }

  Future<void> loadCachedUser() async {
    final cachedData = userRepo.getCachedUserData();
    if (cachedData != null) {
      user.value = UserModel.fromJson(cachedData);
      update();
      print("✅ Loaded user from cache");
    }
  }

  Future<void> getUserProfile() async {
    try {
      Response response = await userRepo.getUserProfile();

      if (response.body == null) {
        print("❌ Response body is null");
        return;
      }

      if (response.statusCode == 200 && response.body['code'] == '00') {
        user.value = UserModel.fromJson(response.body['data']);
        await userRepo.cacheUserData(response.body['data']);
        print("💾 User profile cached successfully");
      } else {
        print("⚠️ Server responded with: ${response.body}");
      }
    } catch (e, s) {
      print('🔥 Error fetching profile: $e, $s');
    } finally {
      update();
    }
  }

  Future<void> clearUserCache() async {
    await userRepo.clearCachedUser();
    user.value = null;
    update();
  }

  Future<void> uploadProfilePicture(XFile imageFile) async {
    try {
      loader.showLoader();
      update();

      Response response = await userRepo.uploadProfileImage(imageFile);

      if (response.statusCode == 200 && response.body['code'] == '00') {
        final newImageUrl = response.body['data'];
        if (user != null) {
          user.value = user.value!.copyWith(profilePicture: newImageUrl);

          await userRepo.cacheUserData(user!.toJson());
          update();
        }

        CustomSnackBar.success(message: 'Profile photo updated!');
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Upload failed',
        );
      }
    } catch (e, s) {
      print('$e,$s');
      CustomSnackBar.failure(message: 'Something went wrong uploading image');
    } finally {
      loader.hideLoader();
      update();
    }
  }

  Future<void> getRecommendedUsers({int limit = 20}) async {
    try {
      loader.showLoader();

      final Response response = await userRepo.getRecommendedUsers(limit: limit);

      final code = response.body['code']?.toString();
      final message = response.body['message'];

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          code == '00') {
        final data = response.body['data'];

        if (data is List) {
          recommendedUsers.value = data
              .map((e) => UserModel.fromJson(e))
              .toList();

          // Since API returns only unfollowed users, initialize followedUserIds as empty
          // followedUserIds.clear();

          // Initialize filteredUsers with all users
          filteredUsers.assignAll(recommendedUsers);

          print("✅ Loaded ${recommendedUsers.length} recommended users");
          print("📊 User roles breakdown:");

          // Debug: Print roles to see what you're getting
          final roleCount = <String, int>{};
          for (var user in recommendedUsers) {
            roleCount[user.role] = (roleCount[user.role] ?? 0) + 1;
            print("   - ${user.name} (${user.role}) ${user.role == 'player' ? '- ${user.playerDetails?.position}' : ''}");
          }
          roleCount.forEach((role, count) {
            print("   $role: $count");
          });

          // Apply filters after loading new data (if any filters are active)
          applyFilters();
        } else {
          CustomSnackBar.failure(
            message: 'Invalid data format received',
          );
        }
      } else {
        CustomSnackBar.failure(
          message: message ?? 'Failed to fetch recommendations',
        );
      }
    } on TimeoutException catch (_) {
      CustomSnackBar.failure(
        message: 'Request timed out. Please try again.',
      );
    } on SocketException catch (_) {
      CustomSnackBar.failure(
        message: 'No internet connection',
      );
    } catch (e, stackTrace) {
      print("❌ Error fetching recommended users: $e");
      print("Stack trace: $stackTrace");
      CustomSnackBar.failure(
        message: 'An unexpected error occurred',
      );
    } finally {
      loader.hideLoader();
    }
  }

  void applyFilters() {
    print("🔍 Starting applyFilters...");
    print("   - Total recommended users: ${recommendedUsers.length}");
    print("   - Search query: '${searchQuery.value}'");
    print("   - Selected role: '${selectedRole.value}'");
    print("   - Selected position: '${selectedPosition.value}'");
    print("   - Selected club: '${selectedClub.value}'");

    List<UserModel> list = List.from(recommendedUsers);

    // 🔍 Filter by search query
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase().trim();
      final beforeCount = list.length;

      list = list.where((user) {
        final nameLower = user.name.toLowerCase();
        final usernameLower = user.username.toLowerCase();
        final bioLower = user.bio?.toLowerCase() ?? '';
        final clubNameLower = user.clubDetails?.clubName.toLowerCase() ?? '';

        return nameLower.contains(query) ||
            usernameLower.contains(query) ||
            bioLower.contains(query) ||
            clubNameLower.contains(query);
      }).toList();

      print("   - After search filter: $beforeCount → ${list.length}");
    }

    // 👤 Filter by role (fan/player/agent/club)
    if (selectedRole.value.isNotEmpty) {
      final beforeCount = list.length;
      list = list.where((user) => user.role == selectedRole.value).toList();
      print("   - After role filter: $beforeCount → ${list.length}");
    }

    // ⚽ Filter by position (only for players)
    if (selectedPosition.value.isNotEmpty) {
      final beforeCount = list.length;
      list = list.where((user) {
        return user.playerDetails?.position == selectedPosition.value;
      }).toList();
      print("   - After position filter: $beforeCount → ${list.length}");
    }

    // 🏟️ Filter by club name
    if (selectedClub.value.isNotEmpty) {
      final clubQuery = selectedClub.value.toLowerCase().trim();
      final beforeCount = list.length;

      list = list.where((user) {
        final clubName = user.clubDetails?.clubName.toLowerCase() ?? '';
        return clubName.contains(clubQuery);
      }).toList();

      print("   - After club filter: $beforeCount → ${list.length}");
    }

    // Update filtered list
    filteredUsers.assignAll(list);

    print("🔎 Filters applied: ${filteredUsers.length} results");
  }

  Timer? _searchDebounce;

  void onSearchChanged(String value) {
    // Cancel previous timer
    _searchDebounce?.cancel();

    // Create new timer
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      searchQuery.value = value;
      applyFilters();
    });
  }

  void clearAllFilters() {
    searchQuery.value = '';
    selectedRole.value = '';
    selectedPosition.value = '';
    selectedClub.value = '';
    applyFilters();
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  Future<void> followUser(String targetId) async {
    try {
      print("➡️ followUser() called for targetId: $targetId");
      loader.showLoader();

      Response response = await userRepo.followUser(targetId);
      loader.hideLoader();

      print(
        "📩 Response from followUser: ${response.statusCode}, ${response.body}",
      );

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: 'User followed successfully');
        final index = recommendedUsers.indexWhere((u) => u.id == targetId);
        print('target index is $index');
        if (index != -1) {
          print(recommendedUsers[index].followers);
          int followersCount = recommendedUsers[index].followers;
          print(followersCount);
          recommendedUsers[index] = recommendedUsers[index].copyWith(
            isFollowed: true,
            followers: followersCount + 1,
          );
          print(recommendedUsers[index].followers);
          recommendedUsers.refresh();
          if (othersProfile.value?.id == recommendedUsers[index].id) {
            othersProfile.value = recommendedUsers[index];
          }
          getOthersProfile(targetId);
          getRecommendedUsers();
          update();
        }
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to follow user',
        );
      }
    } catch (e, s) {
      print("🔥 followUser error: $e\n$s");
      CustomSnackBar.failure(message: 'Error following user: $e');
    }
  }

  Future<void> unfollowUser(String targetId) async {
    try {
      print("➡️ unfollowUser() called for targetId: $targetId");
      loader.showLoader();

      Response response = await userRepo.unfollowUser(targetId);
      loader.hideLoader();

      print(
        "📩 Response from followUser: ${response.statusCode}, ${response.body}",
      );

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: 'User unfollowed successfully');
        final index = recommendedUsers.indexWhere((u) => u.id == targetId);
        print('target index is $index');
        if (index != -1) {
          print(recommendedUsers[index].followers);
          int followersCount = recommendedUsers[index].followers;
          print(followersCount);
          recommendedUsers[index] = recommendedUsers[index].copyWith(
            isFollowed: false,
            followers: followersCount - 1,
          );
          print(recommendedUsers[index].followers);
          recommendedUsers.refresh();
          if (othersProfile.value?.id == recommendedUsers[index].id) {
            othersProfile.value = recommendedUsers[index];
          }
          update();
        }
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to unfollow user',
        );
      }
    } catch (e, s) {
      print("🔥 unfollowUser error: $e\n$s");
      CustomSnackBar.failure(message: 'Error unfollowing user: $e');
    }
  }

  Future<void> blockUser(String targetId) async {
    try {
      print("🚫 blockUser() called for targetId: $targetId");
      Response response = await userRepo.blockUser(targetId);

      print(
        "📩 Response from blockUser: ${response.statusCode}, ${response.body}",
      );

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: 'User blocked successfully');
        final index = recommendedUsers.indexWhere((u) => u.id == targetId);
        if (index != -1) {
          recommendedUsers[index] = recommendedUsers[index].copyWith(
            isBlocked: true,
          );
          recommendedUsers.refresh();
        }
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to block user',
        );
      }
    } catch (e, s) {
      print("🔥 blockUser error: $e\n$s");
      CustomSnackBar.failure(message: 'Error blocking user: $e');
    }
  }

  Future<void> getOthersProfile(String targetId) async {
    try {
      loader.showLoader();
      print("👀 Fetching external profile for $targetId");

      Response response = await userRepo.getOthersProfile(targetId);

      loader.hideLoader();
      print("📩 Response: ${response.statusCode} ${response.body}");

      if (response.statusCode == 200 && response.body['code'] == '00') {
        othersProfile.value = UserModel.fromJson(response.body['data']);
      } else {
        CustomSnackBar.failure(
          message: response.body['message'] ?? 'Failed to load profile',
        );
      }
    } catch (e, s) {
      print("🔥 Error loading external profile: $e\n$s");
      CustomSnackBar.failure(message: 'Error loading profile');
    } finally {
      loader.hideLoader();
    }
  }



  Future<void> getPersonalPosts(String type) async {
    currentPostType = type;

    var localData = userRepo.getCachedPosts(type);
    if (localData.isNotEmpty) {
      postCache[type] = localData.map((e) => PersonalPostModel.fromJson(e)).toList();
      isFirstLoad = false;
      update();
    } else {
      isFirstLoad = true;
      update();
    }

    Response response = await userRepo.getPersonalPosts(type);

    if (response.statusCode == 200) {
      List<dynamic> serverData = response.body['data'];

      userRepo.savePostsToCache(type, serverData);

      postCache[type] = serverData.map((e) => PersonalPostModel.fromJson(e)).toList();

      isFirstLoad = false;
      update();
    } else {
      print(response.body);
    }
  }




}
