import 'package:netshare/data/hivedb/base_hive_client.dart';
import 'package:netshare/data/hivedb/hive_type_constants.dart';
import 'package:netshare/entity/shared_file_entity.dart';

class SharedFileClient extends BaseHiveClient<SharedFile> {
  @override
  String get boxName => HiveTypeConstant.sharedFileBox;

  @override
  Future<SharedFile?> get(dynamic key) async {
    final box = await openBox();
    return null == key ? null : box.get(key);
  }

  @override
  Future<void> add(SharedFile object) async {
    final box = await openBox();
    null == object.name ? await box.add(object) : await box.put(object.name, object);
  }

  @override
  Future<void> update(SharedFile object) async {
    final box = await openBox();
    final objectExist = null != object.name && box.containsKey(object.name);
    objectExist ? await box.put(object.name, object) : await box.add(object);
  }

  @override
  Future<void> delete(SharedFile object) async {
    final box = await openBox();
    if (null != object.name && box.containsKey(object.name)) {
      await box.delete(object.name);
    }
  }
}
