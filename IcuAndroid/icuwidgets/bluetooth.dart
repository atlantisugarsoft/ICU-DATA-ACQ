import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hospital_app/hospitalwidgets/healthinfo.dart';
import 'package:hospital_app/hospitalwidgets/password.dart';
import 'package:hospital_app/providers/bluetoothprovider.dart';
import 'package:hospital_app/providers/connectingprovider.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:hospital_app/providers/passwordprovider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection _connection;
  late SensorDataModel sensorDataModel;
  List<BluetoothDevice> _devices = [];
  late ConnectionProvider _connectionProvider;
  List<int> eepromData = [];

  String receivedDataBuffer = '';
  static const String start_delimiter = '<';
  static const String end_delimiter = '>';
  List<String> sensorValues = [];
  // late ConnectionProvider _connectionProvider;
  String password = '';
  List<String> accumulatedData = [];
  late Timer passTimer;
  late Timer loadTimer;
  late PasswordProvider _passwordProvider;

  @override
  void initState() {
    super.initState();
    _passwordProvider = Provider.of<PasswordProvider>(context, listen: false);
    _passwordProvider.retrievePassword();
    getDevices();
  }

  @override
  void dispose() {
    super.dispose();
    // _connectionProvider.dispose();
    context.read<ConnectionProvider>().dispose();
    _disconnect();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-Ugar'),
      ),
      body: Column(
        children: [
          Expanded(
              child: SizedBox(
            height: 100,
            child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: _devices.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: const Icon(Icons.medical_services),
                    trailing: const Text(
                      "",
                      style: TextStyle(color: Colors.green, fontSize: 15),
                    ),
                    title: Text(_devices[index].name.toString()),
                    // subtitle: Text(context.watch<ConnectionProvider>().connect),
                    onTap: () => {
                      connectToDevice(_devices[index].name),
                      // go to healthInfo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PatientHealthData()),
                      ),
                      // Note
                      if (_connection.isConnected)
                        {
                          connectToDevice(_devices[index].name),
                        }
                    },
                  );
                }),
          )),
        ],
      ),
    );
  }

  void onSensorDataReceived(List<String> values) {
    sensorDataModel = Provider.of<SensorDataModel>(context, listen: false);
    // print('ok data recieved');
    // print(values);
    sensorDataModel.updateValues(values);
  }

  void listenForConnection(value) {
    context.read<ConnectionProvider>().checkConnection(value);
    // _connectionProvider =
    //   Provider.of<ConnectionProvider>(context, listen: false);
    //_connectionProvider.checkConnection(value);
  }

  void listenForDeviceName(value) {
    context.read<DeviceConnectionProvider>().getDeviceName(value);
  }

  void listenForPassword() {
    //context.read<PasswordProvider>().getAndSavePassword(value);
    //print({'password:$value'});
    setState(() {
      password = context.read<PasswordProvider>().storedPassword;
    });

    // context.read<DeviceConnectionProvider>().sendPasswordBackToArduino(value);
  }

  void loadPatientInfo() {
    //  Navigator.push(context,
    //    MaterialPageRoute(builder: (context) => const PatientHealthInfo()));
  }
  void getDevices() async {
    List<BluetoothDevice> devices = await _bluetooth.getBondedDevices();
    // filter out only hospital devices first

    print(_devices.length);
    setState(() {
      _devices = devices;
    });
    // To check later
  }

  void connectToDevice(deviceName) async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    print(deviceName);
    for (BluetoothDevice device in _devices) {
      if (device.name == deviceName) {
        _connection = await BluetoothConnection.toAddress(device.address);
        if (_connection.isConnected) {
          print({'Connected to $deviceName'});
          listenForConnection('Connected');
          listenForDeviceName(device.name);
          listenForPassword();
          // SENDING REQUEST FOR PASSWORD
          _connection.output.add(Uint8List.fromList(utf8.encode('password')));
          await _connection.output.allSent;

          const updateInterval = Duration(seconds: 2);
          passTimer = Timer.periodic(updateInterval, (timer) async {
            _connection.output.add(Uint8List.fromList(utf8.encode(password)));
            print('paaword:$password');

            await _connection.output.allSent;
            passTimer.cancel();
          });

          _connection.input!.listen((Uint8List data) {
            String receivedData = String.fromCharCodes(data);
            print(receivedData);

            receivedDataBuffer += receivedData;
            if (receivedDataBuffer.contains(end_delimiter)) {
              List<String> completeMessages =
                  receivedDataBuffer.split(end_delimiter);
              //  print(completeMessages);
              onSensorDataReceived(completeMessages);
              receivedDataBuffer = completeMessages.last;
            }
          });
        } else {
          print('Not connected');
        }
      }
    }
  }

  void _disconnect() {
    _connection.close();
  }
}
