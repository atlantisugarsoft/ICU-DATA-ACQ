// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:hospital_app/pages/home/widget/bluetooth.dart';
import 'package:hospital_app/pages/home/widget/header.dart';
import 'package:hospital_app/pages/home/widget/import.dart';
import 'package:hospital_app/pages/home/widget/loads.dart';
import 'package:hospital_app/pages/home/widget/patientlists.dart';
import 'package:hospital_app/pages/home/widget/settings.dart';
import 'package:hospital_app/pages/home/widget/space.dart';
import 'package:hospital_app/pages/home/widget/wifi.dart';
import 'package:hospital_app/providers/connectingprovider.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:provider/provider.dart';

import '../widgetlib/button-navigation.dart';
import 'home/widget/bp.dart';
import 'home/widget/connect.dart';

//class HomePage extends StatelessWidget {
//const HomePage({super.key});

// @override
// Widget build(BuildContext context) {
// return Scaffold(
// body: Column(
//children: [
// AppHeader(),
//Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//children: [
// Connect(),
//],
//),
//Row(
// mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//children: [
// Wifi(),
//Bluetooth(),
//],
// ),
// Space(),
//Row(
//mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// ListPatient(),
//],
// ),
//Row(
//mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// children: [
// Loads(),
// ],
// ),
// Row(
//mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//children: [
//  Settings(),
// ],
// ),
//  ButtomNavigation(),
//],
//));
// }
//}

// to achieve the highlight function

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
  }

  void toggleConnection() {
    setState(() {
      isConnected = !isConnected;
      //connectionStatus = isConnected ? 'Connected' : 'Not Connected';
    });
  }

  void activateStatusBar() {
    if (!isConnected) {
      toggleConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween, // Aligns children vertically at the center
        children: [
          AppHeader(),
          Connect(
            isConnected: isConnected,
            onConnect: toggleConnection,
          ),
          //Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Wifi(
                isConnected: isConnected,
                onTap: () {
                  if (!isConnected) {
                    toggleConnection();
                  }
                },
              ),
              //Bluetooth(isConnected: isConnected, onTap: activateStatusBar),
              Bluetooth(
                isConnected: isConnected,
                onTap: () {
                  if (!isConnected) {
                    toggleConnection();
                  }
                  // FOR OFF AND ON
                  if (context.watch<ConnectionProvider>().offOn) {
                    context
                        .read<ConnectionProvider>()
                        .switchBluetoothOnOff(false);
                  }
                },
              ),
            ],
          ),
          Space(),
          if (isConnected) // Only show these widgets if connected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ListPatient(),
                BP(),
              ],
            ),
          Space(),
          if (isConnected) // Only show these widgets if connected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Loads(),
                Settings(),
              ],
            ),
          Space(),
          if (isConnected) // Only show these widgets if connected
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Import(),
              ],
            ),
          Space(),
          ButtomNavigation(),
        ],
      ),
    );
  }
}
