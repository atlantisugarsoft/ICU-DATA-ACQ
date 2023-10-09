import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hospital_app/pages/home/widget/bp.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceConnectionProvider with ChangeNotifier {
  FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;
  late BluetoothConnection _connection;

  static const String end_delimiter = '>';

  List<String> accumulatedData = [];
  List<String> dataListToSend = [];
  String _deviceName = '';
  String _storedDeviceName = '';
  String _messageStatus = '';
  String get deviceName => _deviceName;
  String get messageStatus => _messageStatus;
  String get storedDeviceName => _storedDeviceName;
  void getDeviceName(value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _deviceName = value;
    // print(_deviceName);
    prefs.setString('devicename', value);
    _storedDeviceName = prefs.getString('devicename') ?? 'No name';
    //print('StoredDeviceName: $_storedDeviceName');
    notifyListeners();
  }

  void retrieveStoredDeviceName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    _storedDeviceName = prefs.getString('devicename') ?? 'No name';
    print('StoredDeviceName: $_storedDeviceName');
    notifyListeners();
  }

  Future<void> sendPatientInfoToArduino(patientName, age, gender,
      selectedBpTimer, deviceName, passWord, emergencyNumber, date) async {
    FlutterBluetoothSerial flutterBluetoothSerial =
        FlutterBluetoothSerial.instance;
    // print(deviceName);
    retrieveStoredDeviceName();
    try {
      List<BluetoothDevice> devices =
          await flutterBluetoothSerial.getBondedDevices();
      if (devices.isEmpty) {
        print('No paired devices');
        return;
      }

      BluetoothDevice device =
          devices.firstWhere((device) => device.name == _storedDeviceName);
      _connection = await BluetoothConnection.toAddress(device.address);

      print('Connected to $_storedDeviceName');
      dataListToSend.add(patientName);
      dataListToSend.add(age);
      dataListToSend.add(gender);
      dataListToSend.add(deviceName);
      dataListToSend.add(selectedBpTimer);
      //  print(dataListToSend);

      /* for (int i = 0; i < dataListToSend.length; i++) {
        if (_connection.isConnected) {
          _connection.output
              .add(Uint8List.fromList(utf8.encode(dataListToSend[i])));
          await _connection.output.allSent;
          _messageStatus = 'Message sent';
        }*/
      // print(dataListToSend[i]);
      // ignore: prefer_interpolation_to_compose_strings
      String dataTosend = '<' +
          patientName +
          '<' +
          age +
          '<' +
          passWord +
          '<' +
          gender +
          '<' +
          selectedBpTimer +
          '<' +
          emergencyNumber +
          '<' +
          deviceName +
          '<' +
          date;
      if (_connection.isConnected) {
        _connection.output.add(Uint8List.fromList(utf8.encode(dataTosend)));
        await _connection.output.allSent;

        /* _connection.output.add(Uint8List.fromList(utf8.encode('load')));
        await _connection.output.allSent;*/
        _messageStatus = 'Update Successful';
        print(_messageStatus);
      } else {
        _messageStatus = 'Update Not Succsessful';
      }

      /*if (_connection.isConnected) {
        _connection.output.add(Uint8List.fromList(
            utf8.encode(_deviceController.text + _nameController.text)));
        await _connection.output.allSent;
      }*/
    } catch (e) {
      print('Error: $e');
    } finally {
      // _connection.finish();
      //  try {
      //  if (_connection.isConnected) {
      //   await _connection.finish();
      // print('Connection closed');
      // }
      // } catch (e) {
      // print('Error closing connection: $e');
      // }
    }
    notifyListeners();
  }

/*
  Future<void> sendPasswordBackToArduino(String password) async {
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

      print('Connected');

      if (_connection.isConnected) {
        // SENDING REQUEST FOR PASSWORD
      //  _connection.output.add(Uint8List.fromList(utf8.encode('password')));
       // await _connection.output.allSent;

        _connection.output.add(Uint8List.fromList(utf8.encode(password)));
        await _connection.output.allSent;

        print('password sent');

        _connection.input!.listen((Uint8List data) {
          String receivedData = String.fromCharCodes(data);
          print(receivedData);
          if (receivedData.contains(end_delimiter)) {
            accumulatedData = receivedData.split(end_delimiter);
          }
          //print(accumulatedData);

          //prefs.setString('password', accumulatedData[0]);
        });
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      // _connection.finish();
      try {
        //  if (_connection.isConnected) {
        //  await _connection.finish();
        //  print('Connection closed');
        // }
      } catch (e) {
        print('Error closing connection: $e');
      }
    }
    notifyListeners();
  }*/
}
