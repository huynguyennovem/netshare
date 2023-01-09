import 'package:equatable/equatable.dart';

import 'shared_file_entity.dart';

class AppDataState extends Equatable {
  final Set<SharedFile> sharedFiles;

  const AppDataState({this.sharedFiles = const <SharedFile>{}});

  AppDataState copyWith({
    Set<SharedFile>? sharedFiles,
  }) {
    return AppDataState(
      sharedFiles: sharedFiles ?? this.sharedFiles,
    );
  }

  @override
  List<Object> get props => [sharedFiles];
}
