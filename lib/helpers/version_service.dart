import 'package:package_info_plus/package_info_plus.dart';


class VersionService {
  static String currentVersion = 'unknown';

  static Future<void> init() async {
    try {
      final PackageInfo info = await PackageInfo.fromPlatform();
      currentVersion = info.version;
      print('✔️ App Version Retrieved: $currentVersion');
    } catch (e) {
      print('❌ Failed to load app version: $e');
      currentVersion = 'unknown';
    }
  }
}