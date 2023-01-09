import 'package:flutter/cupertino.dart';
import 'package:netshare/entity/shared_file_entity.dart';

class FileProvider extends ChangeNotifier {
  Set<SharedFile> _files = {};
  Set<SharedFile> get files => _files;

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
}
