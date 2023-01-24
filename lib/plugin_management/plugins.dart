import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:netshare/util/utility_functions.dart';

Future <void> initPlugins() async {
  if(UtilityFunctions.isMobile) {
    await FlutterDownloader.initialize(debug: kDebugMode, ignoreSsl: true);
  }
}