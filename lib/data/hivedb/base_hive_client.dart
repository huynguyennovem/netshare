import 'package:hive_flutter/hive_flutter.dart';

abstract class BaseHiveClient<T> {
  String get boxName;

  Future<Box<T>> openBox() async {
    return await Hive.openBox<T>(boxName);
  }

  Future<T?> get(dynamic key);

  Future<void> add(T object);

  Future<void> update(T object);

  Future<void> delete(T object);
}
