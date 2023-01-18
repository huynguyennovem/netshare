import 'package:flutter/material.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/util/utility_functions.dart';

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
              leading: const Icon(Icons.ios_share_outlined),
              title: const Text('Share file url', style: CommonTextStyle.textStyleNormal),
            ),
          ],
        ),
      ),
    );
  }

  _shareFileUrl() {
    widget.onComplete.call();
    final url = widget.sharedFile.url;
    if(null != url) {
      UtilityFunctions.shareText(widget.sharedFile.url!);
    }
  }
}
