import 'package:netshare/data/global_scope_data.dart';
import 'package:netshare/di/di.dart';
import 'package:netshare/util/utility_functions.dart';

class PreloadData {
  static Future inject() async {
    // current device IP address
    final ip = await UtilityFunctions.getIPAddress() ?? '';
    getIt.get<GlobalScopeData>().updateCurrentDeviceIPAddress(newIpAddress: ip);
  }
}
