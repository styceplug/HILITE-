import 'package:get/get.dart';
import 'package:hilite/helpers/global_loader_controller.dart';
import 'package:hilite/widgets/snackbars.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repo/user_repo.dart';
import '../models/user_model.dart';

class UserController extends GetxController {
  final UserRepo userRepo;
  final SharedPreferences sharedPreferences;

  UserController({required this.userRepo, required this.sharedPreferences});

  GlobalLoaderController loader = Get.find<GlobalLoaderController>();
  Rx<UserModel?> user = Rx<UserModel?>(null);
  var recommendedUsers = <UserModel>[].obs;
  Rxn<UserModel> othersProfile = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    loadCachedUser();
  }

  Future<void> loadCachedUser() async{
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
        CustomSnackBar.failure(message: response.body['message'] ?? 'Upload failed');
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

      Response response = await userRepo.getRecommendedUsers(limit: limit);

      final code = response.body['code']?.toString();
      final message = response.body['message'];

      if ((response.statusCode == 200 || response.statusCode == 201) && code == '00') {
        recommendedUsers.value = (response.body['data'] as List)
            .map((e) => UserModel.fromJson(e))
            .toList();
        print("✅ Loaded ${recommendedUsers.length} recommended users");
      } else {
        CustomSnackBar.failure(
          message: message ?? 'Failed to fetch recommendations',
        );
      }
    } catch (e) {
      CustomSnackBar.failure(message: 'Error: $e');
    } finally {
      loader.hideLoader();
    }
  }

  Future<void> followUser(String targetId) async {
    try {
      print("➡️ followUser() called for targetId: $targetId");
      loader.showLoader();

      Response response = await userRepo.followUser(targetId);
      loader.hideLoader();

      print("📩 Response from followUser: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: 'User followed successfully');
        final index = recommendedUsers.indexWhere((u) => u.id == targetId);
        if (index != -1) {
          recommendedUsers[index] =
              recommendedUsers[index].copyWith(isFollowed: true);
          recommendedUsers.refresh();
        }
      } else {
        CustomSnackBar.failure(
            message: response.body['message'] ?? 'Failed to follow user');
      }
    } catch (e, s) {
      print("🔥 followUser error: $e\n$s");
      CustomSnackBar.failure(message: 'Error following user: $e');
    }
  }

  Future<void> blockUser(String targetId) async {
    try {
      print("🚫 blockUser() called for targetId: $targetId");
      Response response = await userRepo.blockUser(targetId);

      print("📩 Response from blockUser: ${response.statusCode}, ${response.body}");

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: 'User blocked successfully');
        final index = recommendedUsers.indexWhere((u) => u.id == targetId);
        if (index != -1) {
          recommendedUsers[index] =
              recommendedUsers[index].copyWith(isBlocked: true);
          recommendedUsers.refresh();
        }
      } else {
        CustomSnackBar.failure(
            message: response.body['message'] ?? 'Failed to block user');
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

      Response response =
      await userRepo.getOthersProfile(targetId);

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
}