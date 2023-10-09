import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class DataRepositoryModel with ChangeNotifier {
  String deviceName = 'HC-06';
  String patientName = 'Ngozi';
  String dataToSend = '';
  int indexSelected = 0;
  List<double> numbers = [];
  List<String> xValues = [];
  List<String> yValues = [];
  List<String> newDataList = [];
  List<String> outputList = [];
  late DateTime currentDateTime;
  late String formattedDateTime;
  late String amOrPm;
  late int hour, minute;
  List<List<dynamic>> csvTable = [];

  void getDeviceName(deviceName) {
    deviceName = deviceName;
  }

  void getPatientName(patientName) {
    patientName = patientName;
  }

  void getIndexSelected(int index) {
    indexSelected = index;
    // print(indexSelected);
  }

  Future<File> get _externalFile async {
    currentDateTime = DateTime.now();
    formattedDateTime = DateFormat('yyyy-MM-dd').format(currentDateTime);
    // print('Formatted DateTime: $formattedDateTime');
    amOrPm = DateFormat('a').format(currentDateTime);

    hour = currentDateTime.hour;
    minute = currentDateTime.minute;

    final directory = await getExternalStorageDirectory();
    //print(directory);
    notifyListeners();
    return File(
        '${directory!.path}/$deviceName$patientName$formattedDateTime$hour$minute$amOrPm.csv');
    //return File('${directory!.path}/data.txt');
  }

  Future<void> saveData(String data) async {
    final file = await _externalFile;

    await file.writeAsString(data, mode: FileMode.append);
    notifyListeners();
  }

  Future<String> loadData(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        final data = await file.readAsString();
        print(data);
        dataToSend = data;

        // newDataList = dataToSend.split(',');
        // dataToSend = data.replaceAll(RegExp(r'\s+'), '');
        // newDataList = dataToSend.split(' , ');

        List<String> numbersList = RegExp(r'\d+(\.\d+)?')
            .allMatches(dataToSend)
            .map((match) => match.group(0)!)
            .where((number) => number != null)
            .toList();
        //print(numbersList);
        outputList = numbersList.map((inputString) {
          return inputString.replaceAll(RegExp(r'\[|\]'), '');
        }).toList();

        // Print the modified list of strings
        //outputList.forEach((outputString) {
        //print(outputString);
        // });

        notifyListeners();
        return data;
      } else {
        print('File does not exist.');
        return ''; // Return an empty string if the file doesn't exist.
      }
    } catch (e) {
      print('Error loading data: $e');
      return ''; // Return an empty string if there's an error.
    }
  }
// FOR CSV

  Future<List<List<dynamic>>> loadDataFromCsv(String filePath) async {
    // final directory = await getApplicationDocumentsDirectory();
    final file = File(filePath);

    if (await file.exists()) {
      final csvData = await file.readAsString();
      csvTable = const CsvToListConverter().convert(csvData);
//      print(csvTable[4][0]);

      notifyListeners();
      return csvTable;
    } else {
      return [];
    }
  }

  Future<void> saveDataToCsv(List<List<String>> data) async {
    // This opens the file path
    // final file = await _externalFile;
    currentDateTime = DateTime.now();
    formattedDateTime = DateFormat('yyyy-MM-dd').format(currentDateTime);
    // print('Formatted DateTime: $formattedDateTime');
    amOrPm = DateFormat('a').format(currentDateTime);

    hour = currentDateTime.hour;
    minute = currentDateTime.minute;

    final directory = await getExternalStorageDirectory();
    final file = File(
        '${directory!.path}/$deviceName$patientName$formattedDateTime$hour$minute$amOrPm.csv');
    String csvData = const ListToCsvConverter().convert(data);

    await file.writeAsString(csvData);
    notifyListeners();
  }
}
