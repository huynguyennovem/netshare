import 'dart:io';

import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';
import 'package:netshare/entity/source_screen.dart';
import 'package:netshare/ui/common_view/conditional_parent_widget.dart';
import 'package:netshare/ui/list_file/file_menu_options.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:open_filex/open_filex.dart';

class FileTile extends StatefulWidget {
  final SharedFile sharedFile;
  final SourceScreen sourceScreen;
  final Function? onRemoveItem;

  const FileTile({
    Key? key,
    required this.sharedFile,
    required this.sourceScreen,
    this.onRemoveItem,
  }) : super(key: key);

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {

  final hoveringState = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if(SourceScreen.client != widget.sourceScreen)  return;
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
        leftParent: ({child}) => Dismissible(
          direction: DismissDirection.endToStart,
          key: Key(widget.sharedFile.name ?? ''),
          onDismissed: (direction) {
            widget.onRemoveItem?.call();
            context.showSnackbar('${widget.sharedFile.name} is removed');
          },
          background: Container(
            color: Colors.redAccent,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Remove',
              style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        ),
        child: _buildCommon(),
      ),
    );
  }

  _buildCommon() => Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Row(
        children: [
          Icon(widget.sharedFile.fileIcon, color: Theme.of(context).colorScheme.secondary),
          _buildFileInfo(),
          _buildFileState(),
          _buildRemoveButton(),
        ],
      ),
  );

  void _showMenuOptions() {
    if(SourceScreen.client != widget.sourceScreen)  return;

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
        child: Text(
          widget.sharedFile.name ?? 'unknown',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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

  _buildRemoveButton() {
    if(SourceScreen.send != widget.sourceScreen) {
      return const SizedBox.shrink();
    }
    return ValueListenableBuilder(
      valueListenable: hoveringState,
      builder: (context, state, child) {
        if(!state)  return const SizedBox.shrink();
        return InkWell(
          customBorder: const CircleBorder(),
          onTap: () => widget.onRemoveItem?.call(),
          child: const Icon(
            Icons.remove_circle,
            color: Colors.redAccent,
            size: 20.0,
          ),
        );
      },
    );
  }
}
