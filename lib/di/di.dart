import 'package:get_it/get_it.dart';
import 'package:netshare/data/api_service.dart';
import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/data/pref_data.dart';

final getIt = GetIt.instance;

void setupDI() {
  getIt.registerSingleton<GlobalScopeData>(GlobalScopeData());
  getIt.registerSingleton<ApiService>(ApiService());
  getIt.registerSingleton<PrefData>(PrefData());
}
