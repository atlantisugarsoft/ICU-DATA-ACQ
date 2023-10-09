import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/bluetooth.dart';

class ListPatient extends StatelessWidget {
  const ListPatient({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const Bluetooth()),
        );
      },
      style: ElevatedButton.styleFrom(
          foregroundColor: Colors.blue, backgroundColor: Colors.white

          // You can customize other properties like padding, shape, etc. here
          ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment
            .center, // Aligns children vertically at the center

        children: [
          Icon(
            Icons.person,
            size: 75,
            color: Colors.blue,
          ),
          SizedBox(height: 8),
          Text(
            "PATIENT",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }
}
