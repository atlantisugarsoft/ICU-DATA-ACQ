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

class BluetoothDevices extends StatefulWidget {
  const BluetoothDevices({super.key});

  @override
  State<BluetoothDevices> createState() => _BluetoothState();
}

class _BluetoothState extends State<BluetoothDevices> {
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;
  late BluetoothConnection _connection;
  late SensorDataModel sensorDataModel;
  List<BluetoothDevice> _devices = [];
  late ConnectionProvider _connectionProvider;
  // List<int> eepromData = [];
  // bool _connected = false;
  List<String> listOfPatientInfo = [];

  String receivedDataBuffer = '';
  static const String start_delimiter = '<';
  static const String end_delimiter = '>';
  List<String> sensorValues = [];
  // late ConnectionProvider _connectionProvider;
  String password = '';
  String patientName = '';
  String age = '';
  String gender = '';
  String emergencyNumber = '';
  String numberOfdaysAddmited = '';
  List<String> accumulatedData = [];
  List<String> patientData = [];
  String ageSuffix = '';
  late Timer passTimer;

  @override
  void initState() {
    super.initState();

    getDevices();
  }

  @override
  void dispose() {
    _disconnect();
    super.dispose();
    // _connectionProvider.dispose();
    context.read<ConnectionProvider>().dispose();
    passTimer.cancel();
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
                      // Navigator.push(
                      // context,
                      // MaterialPageRoute(
                      //     builder: (context) => const PatientHealthData()),
                      // ),
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

  /*void onSensorDataReceived(List<String> values) {
    sensorDataModel = Provider.of<SensorDataModel>(context, listen: false);
    // print('ok data recieved');
    // print(values);
    sensorDataModel.updateValues(values);
  }
  */

  /* void listenForConnection(value) {
    context.read<ConnectionProvider>().checkConnection(value);
    // _connectionProvider =
    //   Provider.of<ConnectionProvider>(context, listen: false);
    //_connectionProvider.checkConnection(value);
  }*/

  void listenForDeviceName(value) {
    context.read<DeviceConnectionProvider>().getDeviceName(value);
  }

  void listenForPassword(String value) {
    context.read<PasswordProvider>().getAndSavePassword(value);
    print({'password:$value'});
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    RegExp specialCharacterPattern =
        RegExp(r'[!@#\$%^&*()_+[\]{}|\\:;\"<>,.?/~]');
    print(deviceName);
    for (BluetoothDevice device in _devices) {
      if (device.name == deviceName) {
        _connection = await BluetoothConnection.toAddress(device.address);
        if (_connection.isConnected) {
          print({'Connected to $deviceName'});
          //  listenForConnection('Connected');
          // listenForDeviceName(device.name);

          // SENDING REQUEST FOR PASSWORD
          _connection.output.add(Uint8List.fromList(utf8.encode('password')));
          await _connection.output.allSent;

          _connection.input!.listen((Uint8List data) {
            String receivedData = String.fromCharCodes(data);
            //  print(receivedData);
            receivedDataBuffer += receivedData;

            if (receivedData.contains(end_delimiter)) {
              listOfPatientInfo = receivedDataBuffer.split(' ');

              print(listOfPatientInfo);
            }
            //print(accumulatedData);

            setState(() {
              password =
                  listOfPatientInfo[5].replaceAll(specialCharacterPattern, '');
              patientName =
                  listOfPatientInfo[0].replaceAll(specialCharacterPattern, '');
              emergencyNumber =
                  listOfPatientInfo[1].replaceAll(specialCharacterPattern, '');
              age =
                  listOfPatientInfo[2].replaceAll(specialCharacterPattern, '');
              gender =
                  listOfPatientInfo[4].replaceAll(specialCharacterPattern, '');
              ageSuffix =
                  listOfPatientInfo[3].replaceAll(specialCharacterPattern, '');

              print(password);
              prefs.setString('password', password.trim());
              prefs.setString('patientname', patientName);
              prefs.setString('gender', gender);
              prefs.setString('age', age);
              prefs.setString('agesuffix', ageSuffix);
            });

            //prefs.setString('password', accumulatedData[0]);

            /* receivedDataBuffer += receivedData;
            if (receivedDataBuffer.contains(end_delimiter)) {
              List<String> completeMessages =
                  receivedDataBuffer.split(end_delimiter);
              //  print(completeMessages);
             // onSensorDataReceived(completeMessages);
              receivedDataBuffer = completeMessages.last;
            }*/
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
