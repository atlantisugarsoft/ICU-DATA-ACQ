import 'package:flutter/material.dart';
import 'package:hospital_app/pages/details/widgets/bararea.dart';
import 'package:hospital_app/pages/details/widgets/grapharea.dart';
import 'package:hospital_app/pages/details/widgets/namepatient.dart';
import 'package:hospital_app/pages/details/widgets/patientinfo.dart';
import 'package:hospital_app/pages/details/widgets/record.dart';
import 'package:hospital_app/widgetlib/button-navigation.dart';

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //NamePatient(),
          GraphArea(),
          RecordData(),
          BarChart(),
          PatientInfo(),
          ButtomNavigation(),
        ],
      ),
    );
  }
}
