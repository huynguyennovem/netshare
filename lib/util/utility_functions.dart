import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';
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
}
