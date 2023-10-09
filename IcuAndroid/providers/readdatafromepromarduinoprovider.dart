import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class ReadDataFromAdrduinoEpromProvider with ChangeNotifier {
  FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;
  late BluetoothConnection _connection;
  List<String> dataListToSend = [];
  String _deviceName = '';
  String _messageStatus = 'Message not sent';
  String get deviceName => _deviceName;
  String get messageStatus => _messageStatus;
  List<int> eepromData = [];
  void getDeviceName(value) {
    _deviceName = value;
    // print(_deviceName);
    notifyListeners();
  }

  Future<void> connectToArduinoEprom() async {
    FlutterBluetoothSerial flutterBluetoothSerial =
        FlutterBluetoothSerial.instance;
    // print(deviceName);
    try {
      List<BluetoothDevice> devices =
          await flutterBluetoothSerial.getBondedDevices();
      if (devices.isEmpty) {
        print('No paired devices');
        return;
      }

      BluetoothDevice device =
          devices.firstWhere((device) => device.name == 'OKsetname');
      _connection = await BluetoothConnection.toAddress(device.address);

      print('Connected to HC-06');
      _readEEPROMData();
    } catch (e) {
      print('Error: $e');
    } finally {
      // _connection.finish();
      try {} catch (e) {
        print('Error closing connection: $e');
      }
    }
    notifyListeners();
  }

  Future<void> _readEEPROMData() async {
    List<int> response = [];
    if (_connection != null) {
      try {
        //_connection!.output
        //  .add(Uint8List.fromList([82])); // ASCII 'R' for read EEPROM
        _connection.output.add(Uint8List.fromList(utf8.encode('get')));
        await _connection!.output.allSent;
        await for (List<int> data in _connection!.input!) {
          response.addAll(data);
        }
        // final response = await _connection!.input?.join();

        eepromData = response.toList();
      } catch (error) {
        print('Error reading EEPROM data: $error');
      }
      notifyListeners();
    }
  }

  Future<void> _disconnectFromArduino() async {
    if (_connection != null) {
      await _connection!.close();
    }
    notifyListeners();
  }
}
