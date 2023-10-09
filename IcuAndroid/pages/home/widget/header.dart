// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 120,
      child: Stack(
        children: [
          CustomPaint(
            painter: HeaderPainter(),
            size: Size(double.infinity, 200),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.monitor_heart_outlined,
                size: 80,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 40,
            child: CircleAvatar(
              minRadius: 35,
              maxRadius: 35,
              foregroundImage: AssetImage('assets/images/monitor.jpg'),
            ),
          ),
          Positioned(
              left: 120,
              bottom: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ATLANTIS AND UGARSOFT LIMITED',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 5,
                        fontWeight: FontWeight.w300),
                  ),
                  //Text(
                  // "",
                  // style: TextStyle(
                  //color: Colors.white,
                  //fontSize: 20,
                  //fontWeight: FontWeight.w300),
                  //),
                  Text(
                    "PATIENT MONITOR",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

class HeaderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint backcolor = Paint()..color = Color(0xff18b0e8);
    Paint circle = Paint()..color = Colors.white.withAlpha(60);

    canvas.drawRect(
        Rect.fromPoints(Offset(0, 0), Offset(size.width, size.height)),
        backcolor);

    canvas.drawCircle(Offset(size.width * .65, 10), 30, circle);
    canvas.drawCircle(Offset(size.width * .60, 130), 10, circle);
    canvas.drawCircle(Offset(size.width - 10, size.height - 10), 20, circle);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
