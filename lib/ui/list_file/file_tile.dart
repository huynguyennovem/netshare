import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/source_screen.dart';
import 'package:netshare/ui/list_file/file_menu_options.dart';
import 'package:netshare/util/extension.dart';

class FileTile extends StatefulWidget {
  final SharedFile sharedFile;
  final SourceScreen sourceScreen;

  const FileTile({
    Key? key,
    required this.sharedFile,
    required this.sourceScreen,
  }) : super(key: key);

  @override
  State<FileTile> createState() => _FileTileState();
}

class _FileTileState extends State<FileTile> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        if(SourceScreen.client != widget.sourceScreen)  return;
        await Clipboard.setData(ClipboardData(text: widget.sharedFile.url)).then((value) {
          context.showSnackbar('Copied to clipboard');
        });
      },
      onLongPress: () => _showMenuOptions(),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Row(
          children: [
            Icon(widget.sharedFile.fileIcon, color: Theme.of(context).colorScheme.secondary),
            const SizedBox(width: 8.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.sharedFile.name ?? 'unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    widget.sharedFile.url ?? 'unknown',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.black26),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

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
}
