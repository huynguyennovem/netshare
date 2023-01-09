import 'package:shared_preferences/shared_preferences.dart';

class PrefData {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  // Client IP Address
  Future<bool> saveLastConnectedAddress(String address) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString('client_ip_address', address);
  }

  Future<String?> getLastConnectedAddress() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('client_ip_address');
  }

  // Host IP Address
  Future<bool> saveLastHostedAddress(String address) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString('host_ip_address', address);
  }

  Future<String?> getLastHostedAddress() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('host_ip_address');
  }

  // Host picked path dir
  Future<bool> saveLastPickedPathDir(String pickedPath) async {
    final SharedPreferences prefs = await _prefs;
    return prefs.setString('picked_path', pickedPath);
  }

  Future<String?> getLastPickedPathDir() async {
    final SharedPreferences prefs = await _prefs;
    return prefs.getString('picked_path');
  }

}