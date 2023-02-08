// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_file_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedFileAdapter extends TypeAdapter<SharedFile> {
  @override
  final int typeId = 1;

  @override
  SharedFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SharedFile(
      name: fields[0] as String?,
      url: fields[1] as String?,
      savedDir: fields[2] as String?,
      state: fields[3] as SharedFileState,
    );
  }

  @override
  void write(BinaryWriter writer, SharedFile obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.url)
      ..writeByte(2)
      ..write(obj.savedDir)
      ..writeByte(3)
      ..write(obj.state);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
