import 'package:get_it/get_it.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/repository/file_repository.dart';
import 'package:netshare/service/download_service.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/data/hivedb/clients/shared_file_client.dart';
import 'package:netshare/data/pref_data.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerSingleton<GlobalScopeData>(GlobalScopeData());
  getIt.registerSingleton<ApiService>(ApiService());
  getIt.registerSingleton<PrefData>(PrefData());
  getIt.registerSingleton<DownloadService>(DownloadService());

  // hive clients
  getIt.registerSingleton<SharedFileClient>(SharedFileClient());

  // repositories
  getIt.registerSingleton<FileRepository>(FileRepository(getIt.get<ApiService>()));
}
