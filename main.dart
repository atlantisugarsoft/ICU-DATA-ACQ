// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_app/pages/details/detail.dart';
import 'package:hospital_app/pages/home.dart';
import 'package:hospital_app/providers/bluetoothprovider.dart';
import 'package:hospital_app/providers/connectingprovider.dart';
import 'package:hospital_app/providers/dataprovider.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:hospital_app/providers/directoryprovider.dart';
import 'package:hospital_app/providers/filesavingprovider.dart';
import 'package:hospital_app/providers/passwordprovider.dart';
import 'package:hospital_app/providers/patientInfoprovider.dart';
import 'package:hospital_app/providers/readdatafromepromarduinoprovider.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => SensorDataModel()),
      ChangeNotifierProvider(create: (context) => ConnectionProvider()),
      ChangeNotifierProvider(create: (context) => DeviceConnectionProvider()),
      ChangeNotifierProvider(create: (context) => DataProviderModel()),
      ChangeNotifierProvider(create: (context) => DirectoryProviderModel()),
      ChangeNotifierProvider(create: (context) => DataRepositoryModel()),
      ChangeNotifierProvider(create: (context) => PasswordProvider()),
      ChangeNotifierProvider(
          create: (context) => ReadDataFromAdrduinoEpromProvider()),
      ChangeNotifierProvider(create: (context) => PatientinfoProvider()),
    ],
    child: const MyApp(),
  ));
  // const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Monitor',
      theme: ThemeData(
        fontFamily: "Roboto",
        textTheme: TextTheme(
            displayLarge: TextStyle(
          fontSize: 17,
          color: Colors.black,
          fontWeight: FontWeight.w900,
        )),
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => HomePage(),
        '/detail': (context) => DetailsPage(),
      },
      initialRoute: '/',
      //home: DetailsPage(),
    );
  }
}
