import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:provider/provider.dart';

class HospitalSettings extends StatefulWidget {
  const HospitalSettings({super.key});

  @override
  State<HospitalSettings> createState() => _SettingsState();
}

class _SettingsState extends State<HospitalSettings> {
  final _formKey = GlobalKey<FormState>();
  final _patientNameController = TextEditingController();
  final _deviceIdController = TextEditingController();
  final _passWordController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  List<String> ageList = [
    'day old',
    '5 days old',
    '6 months',
    '1-10 years',
    '10-18 years'
        '18-30 years',
    '31-45 years',
    '46-60 years'
  ];
  List<String> genderList = ['Male', 'Female'];
  List<String> bpTimerList = ['1hr', '2hr', '3hr'];

  String selectedAge = '6 months';
  String selectedGender = 'Male';
  String selectedTime = '1hr';
  // String deviceName = '';
  // drop down for bp timer

  @override
  void initState() {
    super.initState();
    setState(() {
      //  deviceName = context.watch<DeviceConnectionProvider>().deviceName;
    });
  }

  @override
  void dispose() {
    super.dispose();
    context.read<DeviceConnectionProvider>().dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-UgarSoft'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Device connected to:${context.watch<DeviceConnectionProvider>().deviceName}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 5),
            Text(
              context.watch<DeviceConnectionProvider>().messageStatus,
              style: const TextStyle(color: Colors.green),
            ),
            const SizedBox(height: 10),
            const Text('Patient Info'),
            const SizedBox(height: 10),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _patientNameController,
                    decoration: const InputDecoration(
                      labelText: 'Patient Name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedAge,
                    onChanged: (newValue) {
                      setState(() {
                        selectedAge = newValue!;
                      });
                    },
                    items:
                        ageList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  DropdownButton<String>(
                    value: selectedGender,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGender = newValue!;
                      });
                    },
                    items: genderList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(
                    height: 20,
                    child: Text('Set time to check Bp:'),
                  ),
                  DropdownButton<String>(
                    value: selectedTime,
                    onChanged: (newValue) {
                      setState(() {
                        selectedTime = newValue!;
                      });
                    },
                    items: bpTimerList
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _deviceIdController,
                    decoration: const InputDecoration(
                      labelText: 'Device Id',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter device id';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  const Text('Admin Info'),
                  TextFormField(
                    controller: _passWordController,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter password';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: _emergencyPhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Phone Number',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    //context.read<DeviceConnectionProvider>().getDeviceName(deviceName)
    //;
    // print(_emergencyPhoneController.text);
    DateTime date = DateTime.now();
    if (_formKey.currentState!.validate()) {
      context.read<DeviceConnectionProvider>().sendPatientInfoToArduino(
          _patientNameController.text,
          selectedAge,
          selectedGender,
          selectedTime,
          _deviceIdController.text,
          _passWordController.text,
          _emergencyPhoneController.text,
          date);
    }
  }
}
