import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/bloodpressure.dart';

class BP extends StatelessWidget {
  const BP({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BloodPressure()),
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
          const Icon(
            Icons.water_drop,
            size: 75,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          Text(
            "BP",
            style: Theme.of(context).textTheme.displayLarge,
          ),
        ],
      ),
    );
  }
}
