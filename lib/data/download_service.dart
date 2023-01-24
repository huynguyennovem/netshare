import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:netshare/entity/internal_error.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

class DownloadService {
  static void startDownloading(String fileUrl, {Function(InternalError)? onError}) async {
    if (UtilityFunctions.isMobile) {
      downloadWithFlutterDownloader(fileUrl: fileUrl, onError: onError);
    } else {
      downloadWithHttp(fileUrl: fileUrl, onError: onError);
    }
  }

  // Download file using flutter_downloader plugin.
  // By default, files will be saved on Download directory on Android and Files on iOS
  static Future<String?> downloadWithFlutterDownloader({
    required String fileUrl,
    Function(InternalError)? onError,
  }) async {
    String? externalStorageDirPath;
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (err) {
        onError?.call(InternalError.getAndroidDownloadPathFailed);
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory?.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath = (await getApplicationDocumentsDirectory()).absolute.path;
    }
    if (null != externalStorageDirPath) {
      final savedDir = Directory(externalStorageDirPath);
      if (!savedDir.existsSync()) {
        await savedDir.create();
      }
      final taskId = await FlutterDownloader.enqueue(
        url: fileUrl,
        savedDir: savedDir.path,
        saveInPublicStorage: true,
      );
      debugPrint('Download taskId: $taskId');
      return taskId;
    }
    return null;
  }

  static void downloadWithHttp({
    required String fileUrl,
    Function(InternalError)? onError,
  }) async {
    final destPath = await getDownloadsDirectory();
    final fileName = path.basename(fileUrl);

    var httpClient = http.Client();
    var request = http.Request('GET', Uri.parse(fileUrl));
    var response = httpClient.send(request);
    if (null == destPath) {
      onError?.call(InternalError.downloadDestNotExist);
      return;
    }
    final fileDestPath = path.join(destPath.path, fileName);
    IOSink out = File(fileDestPath).openWrite();

    List<List<int>> chunks = [];
    int downloaded = 0;
    response.asStream().listen((http.StreamedResponse res) async {
      final contentLen = res.contentLength;
      res.stream
          .map((chunk) {
            if (null != contentLen) {
              final percent = (downloaded * 1.0 / contentLen) * 100;
              debugPrint('Downloading percentage: ${percent.roundToDouble()}%');
            }
            chunks.add(chunk);
            downloaded += chunk.length;
            return chunk;
          })
          .pipe(out)
          .whenComplete(() async {
            if (null != contentLen) {
              final percent = (downloaded * 1.0 / contentLen) * 100;
              debugPrint('Downloading percentage: ${percent.roundToDouble()}%');
            }
            debugPrint('Finish downloading file: $fileDestPath');
            await out.flush();
            await out.close();
            downloaded = 0;
            chunks.clear();
          });
    });
  }
}
