import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class DirectoryProviderModel with ChangeNotifier {
  List<FileSystemEntity> listOffiles2 = [];
  List<String> listOfFilesNames2 = [];
  int _duration = 0;
  int get duration => _duration;
  Future<void> getDir() async {
    final directory = await getExternalStorageDirectory();
    final dir = directory?.path;
    String filesDirectory = '$dir/';
    final myDir = Directory(filesDirectory);

    listOffiles2 = myDir.listSync(recursive: true, followLinks: false);
    listOfFilesNames2 = listOffiles2.map((file) => file.path).toList();

    // print(listOfFilesNames2);
    notifyListeners();
  }

  void getDuration(int duration) {
    _duration = duration;

    notifyListeners();
  }

  void deleteFiles(int value) {
    listOffiles2.removeAt(value);
    print(listOffiles2);
    notifyListeners();
  }
}
