import 'package:flutter/material.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:provider/provider.dart';

class BloodPressure extends StatefulWidget {
  const BloodPressure({super.key});

  @override
  State<BloodPressure> createState() => _BloodPressureState();
}

double portraitWidth = 0.0;
double portraitHeight = 0.0;

class _BloodPressureState extends State<BloodPressure> {
  final _formKey = GlobalKey<FormState>();
  final _bpController1 = TextEditingController();
  final _bpController2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    portraitWidth = MediaQuery.of(context).size.width;
    portraitHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-UgarSoft'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Device connected to:${context.watch<DeviceConnectionProvider>().deviceName}',
              style: const TextStyle(color: Colors.black),
            ),
            const SizedBox(height: 10),
            const Text('Patient Info'),
            const SizedBox(height: 50),
            Align(
              alignment: Alignment.centerLeft, // Adjust horizontal alignment
              child: Container(
                width: 120, // Adjust the width as needed
                child: TextFormField(
                  controller: _bpController1,
                  decoration: InputDecoration(
                    labelText: 'High',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter value';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    child: CustomPaint(painter: LinePainter()))),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerRight, // Adjust horizontal alignment
              child: Container(
                width: 120, // Adjust the width as needed
                child: TextFormField(
                  controller: _bpController2,
                  decoration: InputDecoration(
                    labelText: 'Low',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter value';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(height: 100),
            ElevatedButton(
              onPressed: _submitForm,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      String bp1 = _bpController1.text;
      String bp2 = _bpController2.text;
      // sendDataToArduino(name, deviceId);
    }
  }
}

class LinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.black
    ..strokeWidth = 2
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    // print(size.height);
    canvas.drawLine(Offset(100, size.width / 6),
        Offset(portraitWidth / 2, size.height - 40), _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
