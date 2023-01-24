import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/ui/common_view/confirm_dialog.dart';
import 'package:netshare/data/download_service.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:permission_handler/permission_handler.dart';

class FileMenuOptions extends StatefulWidget {
  final Function onComplete;
  final SharedFile sharedFile;

  const FileMenuOptions({
    Key? key,
    required this.onComplete,
    required this.sharedFile,
  }) : super(key: key);

  @override
  State<FileMenuOptions> createState() => _FileMenuOptionsState();
}

class _FileMenuOptionsState extends State<FileMenuOptions> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
      child: _buildMainLayout(),
    );
  }

  _buildMainLayout() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
              child: Text(
                widget.sharedFile.name ?? '',
                style: CommonTextStyle.textStyleNormal.copyWith(fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ),
            ListTile(
              onTap: () => _shareFileUrl(),
              leading: Icon(
                Icons.ios_share_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Share file url', style: CommonTextStyle.textStyleNormal),
            ),
            ListTile(
              onTap: () => _downloadFile(),
              leading: Icon(
                Icons.cloud_download_outlined,
                color: Theme.of(context).colorScheme.secondary,
              ),
              title: const Text('Download', style: CommonTextStyle.textStyleNormal),
            ),
          ],
        ),
      ),
    );
  }

  _shareFileUrl() {
    widget.onComplete.call();
    final url = widget.sharedFile.url;
    if (null != url) {
      UtilityFunctions.shareText(widget.sharedFile.url!);
    }
  }

  _downloadFile() async {
    widget.onComplete.call();

    final url = widget.sharedFile.url;
    if (null != url) {
      final needGrantPermission = await UtilityFunctions.isNeedGrantStoragePermission;
      if (needGrantPermission) {
        final isPermissionGranted = await UtilityFunctions.checkStoragePermission(
          onPermanentlyDenied: () => showOpenSettingsDialog(context),
        );
        if (isPermissionGranted) {
          DownloadService.startDownloading(url, onError: (error) {
            context.handleInternalError(
              internalError: error,
              shouldShowSnackbar: true,
            );
          });
          if (mounted) {
            context.showSnackbar(
              'Start downloading... Check download progress from notification center',
              duration: const Duration(seconds: 2),
            );
          }
        } else {
          if (mounted) {
            context.showSnackbar('Need to grant permission to continue');
          }
        }
      } else {
        DownloadService.startDownloading(url, onError: (error) {
          context.handleInternalError(
            internalError: error,
            shouldShowSnackbar: true,
          );
        });
        if (mounted) {
          context.showSnackbar(
            'Start downloading... Check output file from Downloads folder',
            duration: const Duration(seconds: 2),
          );
        }
      }
    } else {
      context.showSnackbar('File url is not found');
    }
  }

  showOpenSettingsDialog(BuildContext context) {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return ConfirmDialog(
          header: Text(
            'Open Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          body: const Text(
            'You need to grant permission from app\'s Settings',
            textAlign: TextAlign.center,
          ),
          onConfirm: () => openAppSettings(),
        );
      },
    );
  }
}
