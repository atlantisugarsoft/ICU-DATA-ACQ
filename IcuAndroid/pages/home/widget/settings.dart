import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/password.dart';
import 'package:hospital_app/hospitalwidgets/settings.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PassWord()),
        );
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blue,
          backgroundColor: Colors.white // Background color for the button

          // You can customize other properties like padding, shape, etc. here
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Aligns children vertically at the center

        children: [
          Icon(
            Icons.settings,
            size: 75,
            color: const Color.fromARGB(255, 57, 52, 52),
          ),
          SizedBox(height: 8),
          Text(
            "SETTINGS",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
    //children: [
    //  Padding(
    // padding: const EdgeInsets.symmetric(
    // vertical: 20,
    //horizontal: 30,
    // ),
  }
}
