import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:go_router/go_router.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/source_screen.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/list_file/file_tile.dart';
import 'package:netshare/util/extension.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class SendWidget extends StatefulWidget {
  const SendWidget({Key? key}) : super(key: key);

  @override
  State<SendWidget> createState() => _SendWidgetState();
}

class _SendWidgetState extends State<SendWidget> {
  List<File> _pickedFile = [];
  final ValueNotifier<bool> _isUploading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(8.0),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          'Send',
          style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 20.0, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          children: [
            const SizedBox(height: 32.0),
            FloatingActionButton.large(
              heroTag: const Text("File picker"),
              shape: const CircleBorder(),
              backgroundColor: Colors.blueAccent,
              onPressed: () => _pickFile(),
              child: const Icon(Icons.add, size: 32.0, color: Colors.white),
            ),
            const SizedBox(height: 32.0),
            Flexible(
              child: _pickedFile.isEmpty ? Column(
                children: const [
                  Text('No file picked'),
                  Spacer(),
                ],
              ) : _buildListPickedFiles(),
            ),
            Container(
              margin: const EdgeInsets.all(16.0),
              child: FloatingActionButton.extended(
                onPressed: () {
                  if(_pickedFile.isNotEmpty) {
                    _startUploading(context, _pickedFile);
                  }
                },
                label: Row(
                  children: [
                    const Text('Upload'),
                    const SizedBox(width: 8.0),
                    ValueListenableBuilder(
                      valueListenable: _isUploading,
                      builder: (context, value, child) => value
                          ? const SizedBox(
                              width: 16.0,
                              height: 16.0,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                color: Colors.white,
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
                icon: const Icon(Icons.upload),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildListPickedFiles() => ListView.separated(
    itemBuilder: (context, index) {
      final file = _pickedFile[index];
      return FileTile(
            sharedFile: SharedFile(name: basename(file.path), url: file.path),
            sourceScreen: SourceScreen.send,
          );
        },
    separatorBuilder: (context, index) {
      return const Divider(color: Colors.black12, height: 1.0);
    },
    itemCount: _pickedFile.length,
  );

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _pickedFile = _pickedFile
          ..addAll(result.paths.where((element) => element != null).map((e) => File(e!)).toList());
      });
    } else {
      // User canceled the picker
    }
  }

  void _startUploading(BuildContext context, List<File> files) async {
    setUploadState(uploading: true);

    final result = await getIt<ApiService>().uploadFile(files: files);
    result.fold(
      (l) {
        context.showSnackbar('Failed to upload');
      },
      (r) {
        context.showSnackbar('Upload successful');
        context.read<FileProvider>().addAllSharedFiles(sharedFiles: r.toSet(), isAppending: true);

        Future.delayed(const Duration(seconds: 1), () => Navigator.of(context).pop());
      },
    );

    setUploadState(uploading: false);
  }

  void setUploadState({required bool uploading}) {
    if (uploading) {
      _isUploading.value = true;
    } else {
      _isUploading.value = false;
    }
  }

}
