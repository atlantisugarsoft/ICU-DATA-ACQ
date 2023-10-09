import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PasswordProvider with ChangeNotifier {
  String password = '';
  String storedPassword = '';
  // late SharedPreferences prefs;
  void getAndSavePassword(password) async {
    password = password;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Future<bool> result = prefs.setString('password', password);
    if (await result) {
      print('successful');
    } else {
      print('not saved');
    }
    // print({'passwordShared:$password'});
    notifyListeners();
  }

  Future<void> retrievePassword() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    storedPassword = prefs.getString('password') ?? 'No password';
    // print(storedPassword);
    print({'passwordShared:$storedPassword'});
    notifyListeners();
  }
}
