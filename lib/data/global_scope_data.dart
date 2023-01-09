import 'package:netshare/entity/connection_status.dart';

class GlobalScopeData {
  ConnectionStatus _connectionStatus = ConnectionStatus.idle;
  ConnectionStatus get connectionStatus => _connectionStatus;

  String _connectedIPAddress = '';
  String get connectedIPAddress => _connectedIPAddress;

  void updateConnectionStatus({required ConnectionStatus newStatus}) {
    _connectionStatus = newStatus;
  }

  void updateConnectedIPAddress({required String newIpAddress}) {
    _connectedIPAddress = newIpAddress;
  }

  void resetAllData() {
    _connectedIPAddress = '';
    _connectionStatus = ConnectionStatus.idle;
  }
}