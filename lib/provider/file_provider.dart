import 'package:flutter/cupertino.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';

class FileProvider extends ChangeNotifier {
  final List<SharedFile> _files = [];
  List<SharedFile> get files => _files;

  void addSharedFile({required SharedFile sharedFile}) {
    _files.add(sharedFile);
    notifyListeners();
  }

  void addAllSharedFiles({required Set<SharedFile> sharedFiles, bool isAppending = false}) {
    if(!isAppending) {
      _files.clear();
    }
    _files.addAll(sharedFiles);
    notifyListeners();
  }

  void clearAllFiles() {
    _files.clear();
    notifyListeners();
  }

  void updateFile({
    required String fileName,
    required SharedFileState newFileState,
    required String savedDir,
  }) {
    final oldFile = _files.firstWhere((file) => fileName == file.name);
    final oldIndex = _files.indexOf(oldFile);
    final updatedFile = oldFile.copyWith(state: newFileState, savedDir: savedDir);
    _files[oldIndex] = updatedFile;

    notifyListeners();
  }
}
