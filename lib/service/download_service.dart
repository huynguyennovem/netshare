import 'dart:async';
import 'dart:io';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:netshare/entity/download/download_entity.dart';
import 'package:netshare/entity/download/download_manner.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/internal_error.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class DownloadService {

  StreamController downloadStreamController = StreamController<DownloadEntity>.broadcast();

  Stream<DownloadEntity> get downloadStream =>
      downloadStreamController.stream as Stream<DownloadEntity>;

  void disposeStream() {
    downloadStreamController.close();
  }

  void updateDownloadState(DownloadEntity downloadEntity) {
    downloadStreamController.sink.add(downloadEntity);
  }

  void startDownloading(String fileUrl, {Function(InternalError)? onError}) async {
    if (UtilityFunctions.isMobile) {
      downloadWithFlutterDownloader(fileUrl: fileUrl, onError: onError);
    } else {
      downloadWithHttp(fileUrl: fileUrl, onError: onError);
    }
  }

  // Download file using flutter_downloader plugin.
  // By default, files will be saved on Download directory on Android and Files on iOS
  Future<void> downloadWithFlutterDownloader({
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

      // add to stream
      final fileName = path.basename(fileUrl);
      updateDownloadState(
        DownloadEntity(
          taskId ?? fileName,
          fileName,
          fileUrl,
          savedDir.path,
          DownloadManner.flutterDownloader,
          DownloadState.downloading,
        )
      );
    }
  }

  void downloadWithHttp({
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
    final taskId = const Uuid().v1();

    // Update download state only one time, see (1)
    updateDownloadState(
        DownloadEntity(
          taskId,
          fileName,
          fileUrl,
          destPath.path,
          DownloadManner.http,
          DownloadState.downloading,
        )
    );

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

            // temporary comment out this until use it for download progressing usage (1)
            // (displaying download percentage for eg)
            // updateDownloadState(DownloadEntity(
            //     taskId, fileName, fileUrl, DownloadManner.http, DownloadState.downloading));

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
            updateDownloadState(
                DownloadEntity(
                  taskId,
                  fileName,
                  fileUrl,
                  destPath.path,
                  DownloadManner.http,
                  DownloadState.succeed,
                )
            );
      }).onError((error, stackTrace) => (error, stackTrace) {
        updateDownloadState(
            DownloadEntity(
              taskId,
              fileName,
              fileUrl,
              destPath.path,
              DownloadManner.http,
              DownloadState.failed,
            )
        );
      });
    });
  }
}
