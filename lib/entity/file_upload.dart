import 'package:equatable/equatable.dart';

class FileUpload extends Equatable {
  final String path;

  const FileUpload(this.path);

  @override
  List<Object> get props => [path];

}