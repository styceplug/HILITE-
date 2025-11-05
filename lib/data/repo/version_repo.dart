import 'package:get/get.dart';
import '../../helpers/version_service.dart';
import '../../utils/app_constants.dart';
import '../api/api_client.dart';

class VersionRepo {
  final ApiClient apiClient;

  VersionRepo({required this.apiClient});

  Future<Response> checkAppVersion() async {
    final version = VersionService.currentVersion;
    print('📤 Sending version header: $version');

    return await apiClient.getData(
      AppConstants.VERSION_CHECK,
      headers: {
        'app-version': version,
      },
    );
  }
}