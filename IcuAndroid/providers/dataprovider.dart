import 'package:flutter/material.dart';

class DataProviderModel with ChangeNotifier {
  List<String> fileList = [];
  int _duration = 0;

  int _elapsedSeconds = 0;
  int _elapsedMinutes = 0;
  int _elapsedHours = 0;

  int get elapsedSeconds => _elapsedSeconds;
  int get elapsedMinutes => _elapsedMinutes;
  int get elapsedHours => _elapsedHours;
  int get duration => _duration;
  void getListOfFiles(List<String> listOfFiles) {
    fileList = listOfFiles;
    notifyListeners();
  }

  /* void getDuration(int min, int sec, int hr, int duration) {
    _elapsedMinutes = min;
    _elapsedSeconds = sec;
    _elapsedHours = hr;
    _duration = duration;
    notifyListeners();
  }
  */

  void removeFile(int index) {
    fileList.removeAt(index);
    notifyListeners();
  }
}
