// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_file_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SharedFileStateAdapter extends TypeAdapter<SharedFileState> {
  @override
  final int typeId = 2;

  @override
  SharedFileState read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SharedFileState.none;
      case 1:
        return SharedFileState.downloading;
      case 2:
        return SharedFileState.uploading;
      case 3:
        return SharedFileState.available;
      default:
        return SharedFileState.none;
    }
  }

  @override
  void write(BinaryWriter writer, SharedFileState obj) {
    switch (obj) {
      case SharedFileState.none:
        writer.writeByte(0);
        break;
      case SharedFileState.downloading:
        writer.writeByte(1);
        break;
      case SharedFileState.uploading:
        writer.writeByte(2);
        break;
      case SharedFileState.available:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedFileStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
