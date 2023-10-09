import 'package:flutter/material.dart';

class ConnectionProvider with ChangeNotifier {
  String _connect = 'Not Connected';
  String _connectionType = '';
  bool _iconEnable = false;
  bool _offOn = false;
  String get connect => _connect;
  bool get iconEnable => _iconEnable;
  bool get offOn => _offOn;
  String get connectionType => _connectionType;
  void checkConnection(connectValue) {
    _connect = connectValue;
    if (_connect == 'Connected') {
      _iconEnable = true;
    }
    notifyListeners();
  }

  void checkConnectionType(connectType) {
    _connectionType = connectionType;
    notifyListeners();
  }

  void switchBluetoothOnOff(bool value) {
    // FOR OFF AND ON
    if (_connect == 'Connected') {
      _offOn = true;
    } else {
      _offOn = value;
    }
    notifyListeners();
  }
}

class ConnectDevice with ChangeNotifier {}
