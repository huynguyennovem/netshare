import 'package:netshare/entity/connection_status.dart';

class GlobalScopeData {
  ConnectionStatus _connectionStatus = ConnectionStatus.idle;
  ConnectionStatus get connectionStatus => _connectionStatus;

  String _connectedIPAddress = '';
  String get connectedIPAddress => _connectedIPAddress;

  String _currentDeviceIPAddress = '';
  String get currentDeviceIPAddress => _currentDeviceIPAddress;

  String _currentServerHostingPort = '';
  String get currentServerHostingPort => _currentServerHostingPort;

  void updateConnectionStatus({required ConnectionStatus newStatus}) {
    _connectionStatus = newStatus;
  }

  void updateConnectedIPAddress({required String newIpAddress}) {
    _connectedIPAddress = newIpAddress;
  }

  void updateCurrentDeviceIPAddress({required String newIpAddress}) {
    _currentDeviceIPAddress = newIpAddress;
  }

  void updateCurrentServerHostingPort({required String newPort}) {
    _currentServerHostingPort = newPort;
  }

  void resetAllData() {
    _connectedIPAddress = '';
    _currentDeviceIPAddress = '';
    _currentServerHostingPort = '';
    _connectionStatus = ConnectionStatus.idle;
  }
}