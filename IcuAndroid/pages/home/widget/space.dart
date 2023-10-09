import 'package:flutter/material.dart';

class Space extends StatelessWidget {
  const Space({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: 150,
        color: Colors.white,
      ),
    );
  }
}
