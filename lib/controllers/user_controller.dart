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

  @override
  void onInit() {
    super.onInit();
    loadCachedUser();
  }

  void loadCachedUser() {
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
}