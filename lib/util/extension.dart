import 'package:flutter/material.dart';
import 'package:netshare/config/constants.dart';
import 'package:netshare/entity/download/download_state.dart';
import 'package:netshare/entity/internal_error.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';
import 'package:path/path.dart' as p;

extension ContextExt on BuildContext {

  void showSnackbar(String message, {Duration? duration}) {
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(
      duration: duration ?? const Duration(seconds: 1),
      content: Text(message),
    ));
  }

  void handleInternalError({
    required InternalError internalError,
    bool shouldShowSnackbar = false,
  }) {
    debugPrint(internalError.message);
    if (shouldShowSnackbar) {
      showSnackbar(internalError.message);
    }
  }
}

extension SharedFileExt on SharedFile {
  IconData get fileIcon {
    if(null == name) {
      return Icons.question_mark;
    }
    final extension = p.extension(name!).substring(1).trim().toLowerCase();
    switch(extension) {
      case mTxt:  return Icons.text_fields;
      case mPdf:  return Icons.picture_as_pdf_outlined;
      case mMp4:
      case mAvi:
      case mMov:
        return Icons.video_collection_outlined;
      case mMp3:
      case mWav:
        return Icons.audio_file_outlined;
      case mSvg:
      case mPng:
      case mJpg:
      case mJpeg:
      case mBmp:
      case mWebp:
      return Icons.image_outlined;
      case mGif:
        return Icons.gif;
      case mDoc:
      case mDocX:
        return Icons.text_snippet_outlined;
      case mPpt:
      case mPptX:
        return Icons.slideshow;
      case mXls:
      case mXlsx:
        return Icons.table_chart;
      case mZip:
      case mRar:
        return Icons.folder_zip_outlined;
      case mExe:
        return Icons.data_object_sharp;
      case mApk:
      case mAab:
        return Icons.android;
      case mDmg:
        return Icons.phone_iphone;
    }
    return Icons.question_mark;
  }
}

extension IntExt on int {
  DownloadState get toDownloadState {
    switch(this) {
      case 2: return DownloadState.downloading;
      case 3: return DownloadState.succeed;
      case 4: return DownloadState.failed;
      default:
      return DownloadState.none;
    }
  }
}

extension DownloadStateExt on DownloadState {
  SharedFileState get toSharedFileState {
    switch(this) {
      case DownloadState.downloading: return SharedFileState.downloading;
      case DownloadState.succeed: return SharedFileState.available;
      default:
        return SharedFileState.none;
    }
  }
}

extension TimeFormat on Duration {
  String formatTime() => '$this'.split('.')[0].padLeft(8, '0');
}