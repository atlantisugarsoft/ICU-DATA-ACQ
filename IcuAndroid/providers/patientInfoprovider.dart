import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientinfoProvider with ChangeNotifier {
  String patientName = '';
  String age = '';
  String gender = '';
  String ageSuffix = '';

  Future<void> retrievePatientName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    patientName = prefs.getString('patientname') ?? 'No name';
    // print(storedPassword);
    print({'patientNameStored:$patientName'});
    notifyListeners();
  }

  Future<void> retrievePatientAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    age = prefs.getString('age') ?? 'No age';
    ageSuffix = prefs.getString('agesuffix') ?? 'No age';
    // print(storedPassword);
    print({'patientAgeStored:$age'});
    notifyListeners();
  }

  Future<void> retrievePatientGender() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gender = prefs.getString('gender') ?? 'No gender';
    // print(storedPassword);
    print({'patientGenderStored:$gender'});
    notifyListeners();
  }
}
