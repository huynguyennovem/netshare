import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:netshare/data/hivedb/hive_type_constants.dart';
import 'package:netshare/entity/shared_file_state.dart';

part 'shared_file_entity.g.dart';

@HiveType(typeId: HiveTypeConstant.sharedFile)
class SharedFile extends Equatable {
  @HiveField(0)
  final String? name;

  @HiveField(1)
  final String? url;

  @HiveField(2)
  final String? savedDir;

  @HiveField(3)
  final SharedFileState state;

  const SharedFile({
    this.name,
    this.url,
    this.savedDir,
    this.state = SharedFileState.none,
  });

  factory SharedFile.fromJson(dynamic json) =>
      SharedFile(name: json['name'], url: json['url']);

  SharedFile copyWith({
    String? name,
    String? url,
    String? savedDir,
    SharedFileState? state,
  }) =>
      SharedFile(
        name: name ?? this.name,
        url: url ?? this.url,
        savedDir: savedDir ?? this.savedDir,
        state: state ?? this.state,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    return map;
  }

  @override
  List<Object?> get props => [name, url, savedDir, state];
}
