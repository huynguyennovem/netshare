import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:dartz/dartz.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/entity/api_error.dart';
import 'package:netshare/entity/file_upload.dart';
import 'package:netshare/entity/shared_file_entity.dart';

class ApiService {
  String domain = 'http://${getIt.get<GlobalScopeData>().connectedIPAddress}';  // http://ip:port

  void refreshDomain() {
    domain = 'http://${getIt.get<GlobalScopeData>().connectedIPAddress}';
  }

  Future<Either<ApiError, Set<SharedFile>>> getSharedFiles() async {
    refreshDomain();
    try {
      final endpoint = '$domain/files';
      final response = await http.get(Uri.parse(endpoint));
      if (response.statusCode == 200) {
        final listRes = jsonDecode(response.body) as List;
        return Right(listRes.map((e) => SharedFile.fromJson(e)).toSet());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return const Left(ApiError.empty());
  }

  Future<Either<ApiError, List<SharedFile>>> uploadFile({required List<FileUpload> files}) async {
    refreshDomain();
    final endpoint = '$domain/upload';
    var request = http.MultipartRequest("POST", Uri.parse(endpoint));
    List<http.MultipartFile> newList = [];
    for (var file in files) {
      newList.add(await http.MultipartFile.fromPath('files', file.path));
    }
    request.files.addAll(newList);
    try {
      final response = await request.send();
      final resStr = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        final listRes = jsonDecode(resStr) as List;
        return Right(listRes.map((e) => SharedFile.fromJson(e)).toList());
      } else {
        return const Left(ApiError('Upload failed', 417));
      }
    } catch (e) {
      debugPrint(e.toString());
      return const Left(ApiError.unknown());
    }
  }

}
