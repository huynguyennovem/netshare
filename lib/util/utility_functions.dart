import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class UtilityFunctions {
  static String getRoutePath({required String name}) => '/$name';

  static Future<String?> getIPAddress() async {
    return NetworkInfo().getWifiIP();
  }

  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  static bool get isDesktop => Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  static void shareText(String text) {
    Share.share(text, subject: 'Share by NetShare');
  }

  static Future<bool> checkStoragePermission({
    Function? onGranted,
    Function? onDenied,
    Function? onPermanentlyDenied,
  }) async {
    final status = await Permission.storage.status;
    switch (status) {
      case PermissionStatus.granted:
        onGranted?.call();
        return true;
      case PermissionStatus.permanentlyDenied:
        onPermanentlyDenied?.call();
        return false;
      default:
        {
          final requested = await Permission.storage.request();
          switch (requested) {
            case PermissionStatus.granted:
              onGranted?.call();
              return true;
            case PermissionStatus.permanentlyDenied:
              onPermanentlyDenied?.call();
              return false;
            default:
              onDenied?.call();
              return false;
          }
        }
    }
  }

  static Future<int> get androidSDKVersion async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    final androidInfo = await deviceInfoPlugin.androidInfo;
    return androidInfo.version.sdkInt;
  }

  static Future<bool> get isNeedGrantStoragePermission async {
    if (!Platform.isAndroid) {
      return false;
    }
    final sdkVersion = await androidSDKVersion;
    return 28 >= sdkVersion;
  }
}
