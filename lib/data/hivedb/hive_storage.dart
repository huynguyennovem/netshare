import 'package:hive_flutter/hive_flutter.dart';
import 'package:netshare/entity/shared_file_entity.dart';
import 'package:netshare/entity/shared_file_state.dart';

class HiveStorage {
  Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
  }

  void _registerAdapters() {
    Hive.registerAdapter(SharedFileStateAdapter());
    Hive.registerAdapter(SharedFileAdapter());
  }
}