import 'package:flutter/material.dart';

class Wifi extends StatelessWidget {
  //const Wifi({super.key});
  final bool isConnected;
  final VoidCallback onTap;

  Wifi({required this.isConnected, required this.onTap});

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
                "WIFI",
                style: Theme.of(context).textTheme.displayLarge,
              ),
              IconButton(
                  // onPressed: () {},
                  onPressed: isConnected ? null : onTap,
                  icon: Icon(
                    Icons.wifi,
                    size: 35,
                    color: Colors.blue,
                  ))
            ],
          ),
        ),
      ],
    );
  }
}


 // @override
 // Widget build(BuildContext context) {
   // return ElevatedButton(
      //child: Text('Wifi'),
      //onPressed: isConnected ? onTap : null,
    //);
  
