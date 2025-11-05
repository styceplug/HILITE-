import 'package:get/get.dart';
import '../data/repo/version_repo.dart';

class VersionController extends GetxController {
  final VersionRepo versionRepo;
  VersionController({required this.versionRepo});

  RxBool isChecking = false.obs;
  RxString versionStatus = ''.obs;

  Future<void> checkAppVersion() async {
    isChecking.value = true;

    final response = await versionRepo.checkAppVersion();
    isChecking.value = false;

    print("🔍 Status Code: ${response.statusCode}");
    print("📦 Response Body: ${response.body}");

    if (response.statusCode == 200 &&
        response.body is Map &&
        response.body['code'] == '00') {
      versionStatus.value = 'OK';
    } else if (response.statusCode == 400 || response.statusCode == 426) {
      if (response.body is Map && response.body['code'] == '99') {
        versionStatus.value = response.body['message'] ?? 'Update Required';
      } else {
        versionStatus.value = 'Update Required';
      }
    } else if (response.statusCode == 1 || response.body == null) {
      // 💡 Network error (thrown and caught in getData)
      versionStatus.value = 'no-internet';
    } else {
      versionStatus.value = 'Error checking version';
    }
  }
}