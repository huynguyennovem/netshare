import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';
import 'package:netshare/service/download_service.dart';
import 'package:netshare/ui/common_view/conditional_parent_widget.dart';
import 'package:netshare/ui/list_file/file_menu_options.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:open_filex/open_filex.dart';

class FileTileClient extends StatefulWidget {
  final SharedFile sharedFile;
  final Function? onRemoveItem;

  const FileTileClient({
    Key? key,
    required this.sharedFile,
    this.onRemoveItem,
  }) : super(key: key);

  @override
  State<FileTileClient> createState() => _FileTileClientState();
}

class _FileTileClientState extends State<FileTileClient> {

  final hoveringState = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final file = File('${widget.sharedFile.savedDir}/${widget.sharedFile.name}');
        if(file.existsSync()) {
          OpenFilex.open(file.path);
        } else {
          context.showSnackbar('File does not exist. Please download it first!');
        }
      },
      onLongPress: () => _showMenuOptions(),
      child: ConditionalParentWidget(
        condition: UtilityFunctions.isDesktop,
        rightParent: ({child}) => MouseRegion(
          onEnter: (event) => hoveringState.value = true,
          onExit: (event) => hoveringState.value = false,
          child: child ?? const SizedBox.shrink(),
        ),
        leftParent: ({child}) => child ?? const SizedBox.shrink(),
        child: _buildChild(),
      ),
    );
  }

  _buildChild() => Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Icon(widget.sharedFile.fileIcon, color: Theme.of(context).colorScheme.secondary),
          _buildFileInfo(),
          _buildOptionMenuButton(),
        ],
      ),
  );

  void _showMenuOptions() {
    if(UtilityFunctions.isDesktop) return;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (bsContext) {
        return FileMenuOptions(
          onComplete: () async {
            Navigator.pop(context);
          },
          sharedFile: widget.sharedFile,
        );
      },
    );
  }

  _buildFileInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: Text(
                widget.sharedFile.name ?? 'unknown',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4.0),
            _buildFileState(),
          ],
        ),
      ),
    );
  }

  _buildFileState() {
    final state = widget.sharedFile.state;
    switch(state) {
      case SharedFileState.available:
        return const Icon(Icons.check_circle, color: Colors.green, size: 16.0);
      case SharedFileState.downloading:
      case SharedFileState.uploading:
        return const SizedBox(
            width: 12.0,
            height: 12.0,
            child: CircularProgressIndicator(strokeWidth: 2.0),
          );
      default:
        return const SizedBox.shrink();
    }
  }

  _buildOptionMenuButton() {
    if (UtilityFunctions.isMobile) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: hoveringState,
      builder: (context, state, child) {
        if (!state) return const SizedBox.shrink();
        return PopupMenuButton(
          icon: const Icon(Icons.more_horiz, color: Colors.black54),
          itemBuilder: (context) => <PopupMenuEntry>[
            PopupMenuItem(
              padding: EdgeInsets.zero,
              child: ListTile(
                hoverColor: Colors.transparent,
                onTap: () => _shareFileUrl(),
                leading: Icon(
                  Icons.ios_share_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text('Share file url'),
              ),
            ),
            PopupMenuItem(
              padding: EdgeInsets.zero,
              child: ListTile(
                hoverColor: Colors.transparent,
                onTap: () => _downloadFile(),
                leading: Icon(
                  Icons.cloud_download_outlined,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: const Text('Download'),
              ),
            ),
          ],
        );
      },
    );
  }

  _shareFileUrl() {
    final url = widget.sharedFile.url;
    if (null != url) {
      UtilityFunctions.shareText(widget.sharedFile.url!);
    }
    Navigator.pop(context);
  }

  _downloadFile() async {
    final url = widget.sharedFile.url;
    if (null != url) {
      getIt.get<DownloadService>().startDownloading(url, onError: (error) {
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
    } else {
      context.showSnackbar('File url is not found');
    }
    Navigator.pop(context);
  }
}
