import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class RemoteConfigService {
  static final RemoteConfigService _instance = RemoteConfigService._internal();
  factory RemoteConfigService() => _instance;
  RemoteConfigService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  static const String _keyMinVersion = 'min_required_version';
  static const String _keyStoreUrl = 'store_url';

  String get storeUrl => _remoteConfig.getString(_keyStoreUrl);

  Future<void> initialize() async {
    try {
      await _remoteConfig.setDefaults({
        _keyMinVersion: '1.0.0',
        _keyStoreUrl: 'https://play.google.com/store/apps/details?id=com.heyhappy.komiko',
      });

      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode ? const Duration(minutes: 0) : const Duration(hours: 1),
      ));

      await _remoteConfig.fetchAndActivate();

      if (kDebugMode) {
        debugPrint('Remote Config: Min Version: ${_remoteConfig.getString(_keyMinVersion)}');
      }
    } catch (e) {
      debugPrint('Error initializing Remote Config: $e');
    }
  }

  Future<bool> isUpdateRequired() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final String currentVersionStr = packageInfo.version;
      final String minVersionStr = _remoteConfig.getString(_keyMinVersion);

      return _compareVersions(currentVersionStr, minVersionStr) < 0;
    } catch (e) {
      debugPrint('Error comparing versions: $e');
      return false;
    }
  }

  int _compareVersions(String v1, String v2) {
    List<int> v1Parts = v1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    List<int> v2Parts = v2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    for (int i = 0; i < 3; i++) {
      int part1 = (i < v1Parts.length) ? v1Parts[i] : 0;
      int part2 = (i < v2Parts.length) ? v2Parts[i] : 0;

      if (part1 < part2) return -1;
      if (part1 > part2) return 1;
    }
    return 0;
  }
}
