import 'package:equatable/equatable.dart';

class SharedFile extends Equatable {
  final String? name;
  final String? url;

  const SharedFile({
    this.name,
    this.url,
  });

  factory SharedFile.fromJson(dynamic json) =>
      SharedFile(name: json['name'], url: json['url']);

  SharedFile copyWith({
    String? name,
    String? url,
  }) =>
      SharedFile(
        name: name ?? this.name,
        url: url ?? this.url,
      );

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['name'] = name;
    map['url'] = url;
    return map;
  }

  @override
  List<Object?> get props => [name, url];
}
