import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:netshare/config/styles.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/source_screen.dart';
import 'package:netshare/provider/file_provider.dart';
import 'package:netshare/ui/list_file/file_tile.dart';
import 'package:netshare/util/extension.dart';
import 'package:netshare/util/utility_functions.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class SendWidget extends StatefulWidget {
  const SendWidget({Key? key}) : super(key: key);

  @override
  State<SendWidget> createState() => _SendWidgetState();
}

class _SendWidgetState extends State<SendWidget> {
  List<FileUpload> _pickedFiles = [];
  final ValueNotifier<bool> _isUploading = ValueNotifier(false);
  final ValueNotifier<bool> _draggingNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    super.dispose();
    _isUploading.dispose();
    _draggingNotifier.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Send',
          style: CommonTextStyle.textStyleNormal.copyWith(fontSize: 20.0, color: Colors.white),
        ),
        centerTitle: false,
      ),
      body: _buildBody(),
    );
  }

  _buildBody() {
    if(UtilityFunctions.isMobile) {
      return _buildBodyMobile();
    } else {
      return _buildBodyDesktop();
    }
  }

  _buildBodyMobile() => SizedBox(
    width: double.maxFinite,
    child: Column(
      children: [
        _filePickerButton(),
        Expanded(child: _mainListFiles()),
        _buttonUpload(),
      ],
    ),
  );

  _buildBodyDesktop() => Column(
    children: [
      Expanded(
        child: Row(
          children: [
            _filePickerDragDropSupport(),
            Expanded(child: _mainListFiles()),
          ],
        ),
      ),
      _buttonUpload(),
    ],
  );

  _filePickerDragDropSupport() {
    return DropTarget(
      onDragDone: (detail) {
        setState(() {
          _pickedFiles = _pickedFiles
            ..addAll(detail.files.map((e) => e.toFileUpload).toList());
          _pickedFiles = _pickedFiles.toSet().toList(); // remove duplicate files
        });
      },
      onDragEntered: (detail) {
        _draggingNotifier.value = true;
      },
      onDragExited: (detail) {
        _draggingNotifier.value = false;
      },
      child: Wrap(
        children: [
          ValueListenableBuilder(
            valueListenable: _draggingNotifier,
            builder: (BuildContext context, bool isDragging, Widget? child) {
              return Container(
                padding: const EdgeInsets.all(20.0),
                alignment: Alignment.center,
                margin: const EdgeInsets.only(left: 32.0, right: 32.0, bottom: 32.0, top: 16.0),
                decoration: ShapeDecoration(
                  color: isDragging ? Colors.black26.withAlpha(30) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  shadows: const [
                    BoxShadow(
                      offset: Offset(1.5, 2.5),
                      blurStyle: BlurStyle.outer,
                      blurRadius: 8.0,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.file_open_rounded, color: Colors.black38),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            'Drag and drop files here',
                            style: CommonTextStyle.textStyleNormal.copyWith(
                              color: Colors.black38,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    Text('or',
                      style: CommonTextStyle.textStyleNormal.copyWith(
                        color: Colors.black38,
                      ),
                    ),
                    _filePickerButton(),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  _filePickerButton() => Container(
    margin: const EdgeInsets.only(top: 16.0),
    child: MaterialButton(
      onPressed: () => _pickFile(),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
      color: Theme.of(context).colorScheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add_box, color: Colors.white),
          const SizedBox(width: 8.0),
          Text(
            'Pick files',
            style: CommonTextStyle.textStyleNormal.copyWith(color: Colors.white),
          ),
        ],
      ),
    ),
  );

  _mainListFiles() => _pickedFiles.isEmpty
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/ic_empty.png',
              color: Theme.of(context).colorScheme.secondary,
              width: 48.0,
              height: 48.0,
            ),
            const Text('No picked file', style: CommonTextStyle.textStyleNormal),
          ],
        )
      : _buildListPickedFiles();

  _buildListPickedFiles() {
    final scrollController = ScrollController();
    return Container(
      margin: const EdgeInsets.all(16.0),
      child: Scrollbar(
        controller: scrollController,
        thumbVisibility: true,
        child: ListView.separated(
          controller: scrollController,
          itemBuilder: (context, index) {
            final file = _pickedFiles[index];
            return FileTile(
                  sharedFile: SharedFile(name: path.basename(file.path), url: file.path),
                  sourceScreen: SourceScreen.send,
                  onRemoveItem: () {
                    setState(() {
                      final rawList = _pickedFiles;
                      rawList.removeWhere((element) => element.path == file.path);
                      _pickedFiles = rawList;
                    });
                  },
                );
              },
          separatorBuilder: (context, index) {
            return const Divider(color: Colors.black12, height: 1.0);
          },
          itemCount: _pickedFiles.length,
        ),
      ),
    );
  }

  _buttonUpload() => Container(
    margin: const EdgeInsets.all(16.0),
    child: FloatingActionButton.extended(
      onPressed: () {
        if(_pickedFiles.isNotEmpty) {
          _startUploading(context, _pickedFiles);
        }
      },
      label: Row(
        children: [
          const Text('Upload files'),
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
  );

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        _pickedFiles = _pickedFiles
          ..addAll(result.paths.where((element) => element != null).map((e) => FileUpload(e!)).toList());
        _pickedFiles = _pickedFiles.toSet().toList(); // remove duplicate files
      });
    } else {
      // User canceled the picker
    }
  }

  void _startUploading(BuildContext context, List<FileUpload> files) async {
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
