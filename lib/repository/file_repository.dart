import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/data/hivedb/clients/shared_file_client.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/api_error.dart';
import 'package:netshare/entity/shared_file_entity.dart';

class FileRepository {
  final ApiService apiService;

  FileRepository(this.apiService);

  // Update file state if it's downloaded before/existing on device storage
  Future<Either<ApiError, Set<SharedFile>>> getSharedFilesWithState() async {
    final originalFiles = await apiService.getSharedFiles();
    if (originalFiles.isLeft()) {
      return Left(originalFiles.fold((l) => l, (r) => throw UnimplementedError()));
    }
    final originalFilesRight = originalFiles.getOrElse(() => {});
    final newFileList = await Future.wait(originalFilesRight.map((file) async {
      // check exist in Hive
      final savedAvailableFile = await getIt.get<SharedFileClient>().get(file.name);
      if (null == savedAvailableFile) return file;

      // check exist in device storage
      final savedFile = File('${savedAvailableFile.savedDir}/${savedAvailableFile.name!}');
      final isFileExisting = await savedFile.exists();

      return isFileExisting ? savedAvailableFile : file;
    }));
    return Right(newFileList.toSet());
  }
}
