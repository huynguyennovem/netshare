import 'package:equatable/equatable.dart';
import 'package:netshare/entity/shared_file_state.dart';

class SharedFile extends Equatable {
  final String? name;
  final String? url;
  final SharedFileState state;

  const SharedFile({
    this.name,
    this.url,
    this.state = SharedFileState.none,
  });

  factory SharedFile.fromJson(dynamic json) =>
      SharedFile(name: json['name'], url: json['url']);

  SharedFile copyWith({
    String? name,
    String? url,
    SharedFileState? state,
  }) =>
      SharedFile(
        name: name ?? this.name,
        url: url ?? this.url,
        state: state ?? this.state,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    return map;
  }

  @override
  List<Object?> get props => [name, url, state];
}
