import 'package:package_info_plus/package_info_plus.dart';

class AppVersion {
  static String _version = '';
  static String _buildNumber = '';

  static const String buildDate = '2026-04-24';

  static Future<void> init() async {
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    _buildNumber = info.buildNumber;
  }

  static String get version => _version;
  static String get buildNumber => _buildNumber;

  static String get display => 'v$_version';
  static String get full => 'v$_version ($_buildNumber) · $buildDate';
}
