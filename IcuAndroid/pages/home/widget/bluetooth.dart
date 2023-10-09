import 'package:flutter/material.dart';
import 'package:hospital_app/hospitalwidgets/bluetoothdevices.dart';

class Bluetooth extends StatelessWidget {
  //const Bluetooth({super.key});
  final bool isConnected;
  final VoidCallback onTap;

  Bluetooth({required this.isConnected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 20,
            horizontal: 30,
          ),
          child: Row(
            children: [
              Text(
                "BLUETOOTH",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const BluetoothDevices()),
                    );
                  },
                  //onPressed: isConnected ? null : onTap,
                  icon: const Icon(
                    Icons.bluetooth,
                    size: 35,
                    color: Colors.blueAccent,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}
