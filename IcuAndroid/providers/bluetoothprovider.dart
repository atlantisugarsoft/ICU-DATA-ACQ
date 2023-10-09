import 'package:flutter/material.dart';

class SensorDataModel with ChangeNotifier {
  List<String> stringValues = [];
  // List<String> newValues = [];

  void updateValues(List<String> newValues) {
    //  print('ok model');
    // print(newValues);
    stringValues = newValues;
    // newValues.add('2334444');
    //print(stringValues);
    notifyListeners();
  }
}
