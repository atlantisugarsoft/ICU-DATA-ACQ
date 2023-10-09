import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:hospital_app/hospitalwidgets/bloodpressure.dart';
import 'package:hospital_app/pages/home/widget/space.dart';
import 'package:hospital_app/providers/bluetoothprovider.dart';
import 'package:hospital_app/providers/connectingprovider.dart';
import 'package:hospital_app/providers/deviceconnectedprovider.dart';
import 'package:hospital_app/providers/directoryprovider.dart';
import 'package:hospital_app/providers/filesavingprovider.dart';
import 'package:hospital_app/providers/patientInfoprovider.dart';
import 'package:provider/provider.dart';

late SensorDataModel sensorData;
String heartBeatDisplayValue = '';
String breathingRateDisplayValue = '';
String temperatureDisplayValue = '';
String pulseDisplayValue = '';
String bloodPressureDisplayValue = '';
double warningCircleValue = 0.0;

class PatientHealthData extends StatelessWidget {
  const PatientHealthData({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlantis-Ugar'),
      ),
      body: const PatientScreen(),
    );
  }
}

class PatientScreen extends StatefulWidget {
  const PatientScreen({super.key});

  @override
  PatientScreenState createState() => PatientScreenState();
}

double landScapeWidth = 0.0;
double landScapeHeight = 0.0;

class PatientScreenState extends State<PatientScreen> {
  late DataRepositoryModel _dataRepositoryModel;
  double temperatureLevel = 1; // Initial position of temperature
  double dripLevel = 1;
  late DateTime now;
  late String formattedDate;
  late String formattedTime;
  final List<FlSpot> heartdataList = [];
  final List<FlSpot> breathingDataList = [];
  final List<FlSpot> bpDataLlist = [];
  final List<FlSpot> tempDataList = [];
  double portraitWidth = 0.0;
  double portraitHeight = 0.0;
  List<String> sensorDataList = [];
  String heartBeat2 = '';
  String breathingRate2 = '';
  String temperature2 = '';
  String pulse2 = '';
  String bloodPressure2 = '';
  String dripLevel2 = '';
  double simulatedDripLevel = 0.0;
  List<String> sensorDataList2 = [];
  double xOffSet = 10;
  double yOffSet = 10;
  IconData recordIcon = Icons.fiber_manual_record;
  IconData stopIcon = Icons.stop;
  IconData pauseIcon = Icons.pause;
  Color recordIconColor = Colors.green; // Color for the Record icon
  Color stopIconColor = Colors.red;
  Color pauseIconColor = Colors.orange;

  bool isRecording = false; // To control recording
  int elapsedSeconds = 0; // To display elapsed time in seconds
  int elapsedMinutes = 0; // To display elapsed time in minutes
  int elapsedHours = 0; // To display elapsed time in hours
  Timer? recoderTimer;
  late Timer dripTimer, warningTimer;

  List<List<String>> rawdata = [
    ["Time", "Heartbeat", 'Breathing'],
  ];
  late PatientinfoProvider _patientInfoProvider;
  @override
  void initState() {
    super.initState();

    // now = DateTime.now();
    // formattedDate = DateFormat('yyyy-MM-dd').format(now);
    // formattedTime = DateFormat('HH:mm:ss').format(now);
    _dataRepositoryModel = DataRepositoryModel();
    // print(landScapeHeight);
    _patientInfoProvider =
        Provider.of<PatientinfoProvider>(context, listen: false);
    _patientInfoProvider.retrievePatientName();
    _patientInfoProvider.retrievePatientAge();
    _patientInfoProvider.retrievePatientGender();
    useTimerDripLevel();
    warningTimerFunction();

    now = DateTime.now();
  }

  @override
  void dispose() {
    super.dispose();
    // sensorData.dispose();
    context.read<ConnectionProvider>().dispose();
    // context.read<DeviceConnectionProvider>().dispose();
    recoderTimer?.cancel();
    dripTimer.cancel();
    warningTimer.cancel();
  }

  LineChartData heartLineChartData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: heartdataList,
          isCurved: true,
          color: Colors.red,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: heartdataList.isNotEmpty ? heartdataList.first.x : 0,
      maxX: heartdataList.isNotEmpty ? heartdataList.last.x : 1,
      minY: 0.0,
      maxY: 1300,
    );
  }

  LineChartData bpLineChartData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: bpDataLlist,
          isStepLineChart: true,
          color: Colors.green,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: false),
        ),
      ],
      gridData: const FlGridData(show: true),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      minX: bpDataLlist.isNotEmpty ? bpDataLlist.first.x : 0,
      maxX: bpDataLlist.isNotEmpty ? bpDataLlist.last.x : 1,
      minY: 0,
      maxY: 1300,
    );
  }

  LineChartData breathingLineChartData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: breathingDataList,
          isCurved: true,
          color: Colors.yellow,
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true),
      minX: breathingDataList.isNotEmpty ? breathingDataList.first.x : 0,
      maxX: breathingDataList.isNotEmpty ? breathingDataList.last.x : 1,
      minY: 0,
      maxY: 1300,
    );
  }

  LineChartData temperatureLineChartData() {
    return LineChartData(
      lineBarsData: [
        LineChartBarData(
          spots: tempDataList,
          isStepLineChart: true,
          color: Colors.blue,
          dotData: const FlDotData(show: false),
        ),
      ],
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      gridData: const FlGridData(show: true),
      minX: breathingDataList.isNotEmpty ? breathingDataList.first.x : 0,
      maxX: breathingDataList.isNotEmpty ? breathingDataList.last.x : 1,
      minY: 0,
      maxY: 1300,
    );
  }

  @override
  Widget build(BuildContext context) {
    //ALL SENSOR VALUES COME IN HERE

    sensorData = Provider.of<SensorDataModel>(context);
    // print(sensorData.stringValues);
    // print('Hello okay');
    for (String data in sensorData.stringValues) {
      sensorDataList = data.split(',');

      try {
        //print(sensorDataList[0]);
        heartBeat2 = sensorDataList[2];
        heartBeatDisplayValue = heartBeat2;

        breathingRate2 = sensorDataList[0];
        breathingRateDisplayValue = breathingRate2;

        pulse2 = sensorDataList[3];
        dripLevel2 = sensorDataList[4];
        temperature2 = sensorDataList[1];
        temperatureDisplayValue = temperature2;
        bloodPressure2 = sensorDataList[0];
        bloodPressureDisplayValue = bloodPressure2;

        getHeartBeatData();
        getBreathingData();
        getBloodPressureData();
        getTemperatureData();
        print('Breathing$breathingRate2');
        // getPulseData();
        // print(dripLevel2);
      } catch (e) {
        print(e);
      }
    }

    portraitWidth = MediaQuery.of(context).size.width;
    portraitHeight = MediaQuery.of(context).size.height;
    landScapeWidth = portraitWidth;
    landScapeHeight = portraitHeight;

    print('ScreenHeight$portraitHeight');
    print('ScreenWidth$portraitWidth');
    return Scaffold(
        body: Container(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
              child: Text(
            context.watch<ConnectionProvider>().connect,
            style: const TextStyle(color: Colors.green),
          )),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2,
                  height: 30,
                  child: heartdataList.isNotEmpty
                      ? LineChart(
                          heartLineChartData(),
                        )
                      : Center(
                          child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2,
                          height: MediaQuery.of(context).size.height * 2,
                          child: CustomPaint(painter: LinePainter()),
                        ))),
            ),
          ),
          // THE VERTICAL LINE FOR HEARTBEAT
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 4,
                    child: CustomPaint(
                      painter: HeartVerticalLinePainter(),
                    ),
                  ),
                )),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2,
                  height: 30,
                  child: breathingDataList.isNotEmpty
                      ? LineChart(
                          breathingLineChartData(),
                        )
                      : Center(
                          child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2,
                          height: MediaQuery.of(context).size.height * 2,
                          child: CustomPaint(painter: LinePainter()),
                        ))),
            ),
          ),
          // BREATHING VERTICAL LINE
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 4,
                    child: CustomPaint(
                      painter: BreathingVerticalLinePainter(),
                    ),
                  ),
                )),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2,
                  height: 50,
                  child: bpDataLlist.isNotEmpty
                      ? LineChart(
                          bpLineChartData(),
                        )
                      : Center(
                          child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2,
                          height: MediaQuery.of(context).size.height * 2,
                          child: CustomPaint(painter: LinePainter()),
                        ))),
            ),
          ),
          // BREATHING VERTICAL LINE
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 4,
                    child: CustomPaint(
                      painter: BpVerticalLinePainter(),
                    ),
                  ),
                )),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                  width: MediaQuery.of(context).size.width * 2,
                  height: 50,
                  child: tempDataList.isNotEmpty
                      ? LineChart(
                          temperatureLineChartData(),
                        )
                      : Center(
                          child: SizedBox(
                          width: MediaQuery.of(context).size.width * 2,
                          height: MediaQuery.of(context).size.height * 2,
                          child: CustomPaint(painter: LinePainter()),
                        ))),
            ),
          ),
          // TEMPERATURE VERTICAL LINE
          Expanded(
            child: SizedBox(
                width: MediaQuery.of(context).size.width * 2,
                child: Center(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4,
                    height: MediaQuery.of(context).size.height / 4,
                    child: CustomPaint(
                      painter: TempVerticalLinePainter(),
                    ),
                  ),
                )),
          ),

          Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                '      Temperature: $temperature2°C        Drip Level: $simulatedDripLevel%',
                style: const TextStyle(fontSize: 17, color: Colors.white),
              )),

          Expanded(
              child: SizedBox(
            width: 2,
            child: CustomPaint(
              painter: TemperatureLevelPainter(
                  // TAKE NOTE portrateheight
                  temperatureLevel,
                  portraitWidth - 485,
                  portraitWidth - 353),
            ),
          )),
          Expanded(
              child: SizedBox(
            child: CustomPaint(
              // TAKE NOTE portrateheight
              painter: DripLevelPainter(
                  dripLevel, portraitWidth - 270, portraitWidth - 387),
            ),
          )),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                  // alignment: Alignment.center,
                  child: IconButton(
                onPressed: () {
                  if (!isRecording) {
                    // Start recording
                    setState(() {
                      isRecording = true;
                    });
                    // CHECK IF THERE IS DATA TO RECORD

                    _startRecording();
                  } else {
                    // Pause recording
                    setState(() {
                      isRecording = false;
                    });
                    // _stopRecording();
                    _pauseRecording();
                  }
                },
                icon: Icon(
                  isRecording ? pauseIcon : recordIcon,
                  color: isRecording ? Colors.orange : Colors.grey,
                  size: portraitWidth - 310,
                ),
              )),
              IconButton(
                onPressed: () {
                  if (isRecording) {
                    // Stop recording
                    setState(() {
                      isRecording = false;
                    });
                    _stopRecording();
                  }
                },
                icon: Icon(
                  stopIcon,
                  color: stopIconColor,
                  size: portraitWidth - 305, // Adjust the size as needed
                ),
              ),
            ],
          ),
          Text(
            '   ${elapsedHours.toString().padLeft(2, '0')}:${elapsedMinutes.toString().padLeft(2, '0')}:${elapsedSeconds.toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 20, color: Colors.white),
          ),
          SizedBox(
            height: portraitWidth - 320,
          ),
          Align(
              alignment: Alignment.center,
              child: Text(
                '${context.watch<PatientinfoProvider>().patientName.toUpperCase()} .E  :  ${context.watch<PatientinfoProvider>().age}${'YRS'}  :  ${context.watch<PatientinfoProvider>().gender.toUpperCase()}',
                style: const TextStyle(fontSize: 17, color: Colors.white),
              )),
          SizedBox(
            height: portraitWidth - 350,
          ),
          const Align(
              alignment: Alignment.center,
              child: Text(
                'Diagnosis: ',
                style: TextStyle(fontSize: 17, color: Colors.white),
              )),
          SizedBox(
            height: portraitWidth - 350,
          ),
          Align(
              alignment: Alignment.center,
              child: Text(
                '${now.year} : ${now.month} : ${now.day}:       4 DAYS',
                style: const TextStyle(fontSize: 17, color: Colors.white),
              )),
          SizedBox(
              // height: portraitWidth - 350,
              ),

          SizedBox(
            height: portraitHeight / 10,
          ),
        ],
      ),
    ));
  }

  void useTimerDripLevel() {
    //int randomHeartBeat = Random().nextInt(1000) + 300;
    int counter = 0;
    const updateInterval = Duration(seconds: 5);
    dripTimer = Timer.periodic(updateInterval, (timer) async {
      //  int randomDripLevel = Random().nextInt(5);
      List<double> listOfDripLevel = [
        1,
        0.7,
        0.5,
        0.2,
      ];
      // print(randomHeartBeat);
      setState(() {
        counter += 1;
        if (counter >= listOfDripLevel.length) {
          counter = 0;
        }
        dripLevel = listOfDripLevel[counter];
        // warningCircleValue = listOfDripLevel[counter];
        simulatedDripLevel = dripLevel * 100;
      });
      print('SimulatedDripLevel: $warningCircleValue');
    });

    /* setState(() {
      breathingDataList.add(FlSpot(
          DateTime.now().millisecondsSinceEpoch.toDouble(),
          randomHeartBeat.toDouble()));
      if (breathingDataList.length > 20) {
        breathingDataList.removeAt(0);
      }
    });*/
    // print(breathingDataList);
  }

  void warningTimerFunction() {
    int counter = 0;
    const updateInterval = Duration(seconds: 2);
    warningTimer = Timer.periodic(updateInterval, (timer) async {
      //  int randomDripLevel = Random().nextInt(5);
      List<double> listOfDataLevel = [
        1,
        0.7,
        0.5,
        0.2,
      ];
      // print(randomHeartBeat);
      setState(() {
        counter += 1;
        if (counter >= listOfDataLevel.length) {
          counter = 0;
        }
        warningCircleValue = listOfDataLevel[counter];
        // simulatedDripLevel = dripLevel * 100;
      });
      print('SimulatedDripLevel: $warningCircleValue');
    });
  }

  void getBreathingData() {
    setState(() {
      // breathingRate2 = sensorData.stringValues[0];
    });
    double? parsedValue = double.tryParse(breathingRate2);
    if (parsedValue != null) {
      setState(() {
        breathingDataList.add(FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(),
            double.parse(breathingRate2)));
        if (breathingDataList.length > 20) {
          breathingDataList.removeAt(0);
        }
      });
      //    print(breathingDataList);
    } else {
      print("Invalid breathing rate value: $breathingRate2");
    }
  }

/*
  void getPulseData() {
    setState(() {
      // pulse2 = sensorData.stringValues[3];
      bpDataLlist
          .add(FlSpot(DateTime.now().second.toDouble(), double.parse(pulse2)));
      if (bpDataLlist.length > 20) {
        bpDataLlist.removeAt(0);
      }
    });
  }
 */
  void getHeartBeatData() {
    double? parsedValue = double.tryParse(heartBeat2);
    if (parsedValue != null) {
      setState(() {
        // heartBeat2 = sensorData.stringValues[0];
        heartdataList.add(FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(), parsedValue));
        if (heartdataList.length > 20) {
          heartdataList.removeAt(0);
        }
      });
      //print(heartdataList);
    }
  }

  void getTemperatureData() {
    //setState(() {
    // tempDataList.add(FlSpot(DateTime.now().millisecondsSinceEpoch.toDouble(),
    //   double.parse(temperature2)));
    //if (tempDataList.length > 20) {
    // tempDataList.removeAt(0);
    // }
    // });
    double? parsedValue = double.tryParse(temperature2);
    if (parsedValue != null) {
      setState(() {
        tempDataList.add(FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(), parsedValue));
        if (tempDataList.length > 20) {
          tempDataList.removeAt(0);
        }
      });
    }
  }

  void getDripData() {
    setState(() {});
  }

  void getBloodPressureData() {
    double? parsedValue = double.tryParse(bloodPressure2);
    if (parsedValue != null) {
      setState(() {
        bpDataLlist.add(FlSpot(
            DateTime.now().millisecondsSinceEpoch.toDouble(), parsedValue));
        if (bpDataLlist.length > 20) {
          bpDataLlist.removeAt(0);
        }
      });
    }
  }

  // TO GET THE RAW DATA BEFORE TO BE SAVED
  List<String> getRawData() {
    final time =
        "${DateTime.now().millisecondsSinceEpoch.toDouble() / 1000000000000}";
    final heartBeatRate = heartBeat2;
    //final breathingTime =
    //  "${DateTime.now().millisecondsSinceEpoch.toDouble() / 1000000000000}";
    final breathing = breathingRate2;

    return [time, heartBeatRate, breathing];
  }

  void _startRecording() {
    // dataUpdateTimer?.cancel(); // Cancel any existing timer

    // Start a new timer for recording
    recoderTimer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        //duration++;
        elapsedSeconds++;
        if (elapsedSeconds == 60) {
          elapsedSeconds = 0;
          elapsedMinutes++;
        }
        if (elapsedMinutes == 60) {
          elapsedMinutes = 0;
          elapsedHours++;
        }
      });
      // record here
      // Process the datapoints to remove [()] before saving
      //print(dataPoints);
      // _repository.saveData(dataPoints.toString());
      // _dataRepositoryModel.saveData(dataPoints.toString());
      //context.read<DirectoryProviderModel>().getDuration(duration);

      final rawData = getRawData();
      // CHECK IF THERE IS DATA TO SAVE
      // print(rawData);
      if (rawdata.isNotEmpty) {
        rawdata.add(rawData);
        _dataRepositoryModel.saveDataToCsv(rawdata);
      } else {
        print('No data found');
        recoderTimer?.cancel();
      }

      // context.read<DirectoryProviderModel>().getDuration(duration);
    });
    setState(() {
      recordIcon = Icons.fiber_manual_record;
      recordIconColor = pauseIconColor;
      pauseIcon = Icons.pause;
      pauseIconColor = Colors.green;
      stopIcon = Icons.stop;
      stopIconColor = Colors.red;
    });
  }

  void _pauseRecording() {
    recoderTimer?.cancel();
    setState(() {
      isRecording = false;
      recordIcon = Icons.fiber_manual_record;
      recordIconColor = Colors.green;
      pauseIcon = Icons.pause;
      pauseIconColor = pauseIconColor;
      stopIcon = Icons.stop;
      stopIconColor = Colors.red;
    });
  }

  void _stopRecording() {
    recoderTimer?.cancel();
    setState(() {
      elapsedHours = 0;
      elapsedMinutes = 0;
      elapsedSeconds = 0;
      isRecording = false;
      recordIcon = Icons.fiber_manual_record;
      recordIconColor = Colors.green;
      pauseIcon = Icons.pause;
      pauseIconColor = pauseIconColor;
      stopIcon = Icons.stop;
      stopIconColor = Colors.red;
    });
    // save the data here
  }
}

class LinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.blue
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    // print(size.height);
    canvas.drawLine(Offset(0, size.height / 7),
        Offset(landScapeWidth, size.height / 7), _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TemperatureLevelPainter extends CustomPainter {
  final double temperatureLevel;
  final double tankXOffset;
  final double tankYOffset;

  TemperatureLevelPainter(
      this.temperatureLevel, this.tankXOffset, this.tankYOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final double chartWidth = size.width;
    final double chartHeight = size.height;
    final double lineY = chartHeight * temperatureLevel;
    final double boxWidth = 20;
    final double tankHeight = chartHeight;
    final double temperatureHeight = lineY;

    Color temperatureColor;

    // Determine temperature color based on line position
    if (temperatureLevel >= 0.75) {
      temperatureColor = Colors.red;
    } else if (temperatureLevel < 0.6) {
      temperatureColor = Colors.yellow;
    } else {
      temperatureColor = Colors.red;
    }

    // Draw tank with border
    final tankRect = Rect.fromPoints(
      Offset((chartWidth - boxWidth) / 2 + tankXOffset, tankYOffset),
      Offset(
          (chartWidth + boxWidth) / 2 + tankXOffset, tankHeight + tankYOffset),
    );
    final tankPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke // Set to stroke
      ..strokeWidth = 3; // Border width
    canvas.drawRect(tankRect, tankPaint);

    // Draw temperature with stroke
    final waterRect = Rect.fromPoints(
      Offset((chartWidth - boxWidth) / 2 + tankXOffset,
          tankHeight - temperatureHeight + tankYOffset),
      Offset(
          (chartWidth + boxWidth) / 2 + tankXOffset, tankHeight + tankYOffset),
    );
    final waterPaint = Paint()
      ..color = temperatureColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawRect(waterRect, waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DripLevelPainter extends CustomPainter {
  final double dripLevel;
  final double tankXOffset;
  final double tankYOffset;

  DripLevelPainter(this.dripLevel, this.tankXOffset, this.tankYOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final double chartWidth = size.width;
    final double chartHeight = size.height;
    final double lineY = chartHeight * dripLevel;
    final double boxWidth = 20;
    final double tankHeight = chartHeight;
    final double waterHeight = lineY;

    Color waterColor = Colors.green;

    // Determine water color based on line position
    /*
    if (dripLevel >= 0.75) {
      waterColor = Colors.green;
    } else if (dripLevel <= 0.5) {
      waterColor = Colors.yellow;
    } else {
      waterColor = Colors.red;
    }
*/
    if (dripLevel >= 0.75) {
      waterColor = Colors.green;
    }
    if (dripLevel == 0.5) {
      waterColor = Colors.orange;
    }
    if (dripLevel == 0.2) {
      waterColor = Colors.red;
    }
    // Draw tank with border
    final tankRect = Rect.fromPoints(
      Offset((chartWidth - boxWidth) / 2 + tankXOffset, tankYOffset),
      Offset(
          (chartWidth + boxWidth) / 2 + tankXOffset, tankHeight + tankYOffset),
    );
    final tankPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke // Set to stroke
      ..strokeWidth = 3; // Border width
    canvas.drawRect(tankRect, tankPaint);

    // Draw water with stroke
    final waterRect = Rect.fromPoints(
      Offset((chartWidth - boxWidth) / 2 + tankXOffset,
          tankHeight - waterHeight + tankYOffset),
      Offset(
          (chartWidth + boxWidth) / 2 + tankXOffset, tankHeight + tankYOffset),
    );
    final waterPaint = Paint()
      ..color = waterColor
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0
      ..strokeJoin = StrokeJoin.miter;
    canvas.drawRect(waterRect, waterPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class HeartVerticalLinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    canvas.drawLine(Offset(size.width - 220, -50),
        Offset(size.width - 220, size.height - 20), _paintLine);

    // WARNING SIGN
    print('warningValue $warningCircleValue');
    Color warningColor = Colors.white;
    PaintingStyle ps = PaintingStyle.stroke;

    if (warningCircleValue == 0.75) {
      // warningColor = Colors.green;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.5) {
      // warningColor = Colors.yellow;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.2) {
      warningColor = Colors.red;
      ps = PaintingStyle.fill;
    }

    final paintCircle = Paint()
      ..color = warningColor
      ..strokeWidth = 0
      ..style = ps
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(size.width + 100, -36), 20, paintCircle);

    const maxLabel = 'Max';
    final maxLabelSize = TextPainter(
      text: const TextSpan(text: maxLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize.layout();
    maxLabelSize.paint(canvas, Offset(size.width - 220, -55));

    String heartBeatLabel = 'Heart Beat $heartBeatDisplayValue bpm';
    final heartLabelSize = TextPainter(
      text: TextSpan(text: heartBeatLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    heartLabelSize.layout();
    heartLabelSize.paint(canvas, Offset(size.width - 150, -55));

    const minLabel = 'Min';
    final minLabelSize = TextPainter(
      text: const TextSpan(text: minLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize.layout();
    minLabelSize.paint(canvas, Offset(size.width - 220, 1));

    const zeroLabel = '0';
    final zeroLabelSize = TextPainter(
      text: const TextSpan(text: zeroLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize.layout();
    zeroLabelSize.paint(canvas, Offset(size.width - 220, -25));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BreathingVerticalLinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    canvas.drawLine(Offset(size.width - 220, -44),
        Offset(size.width - 220, size.height - 18), _paintLine);

    // WARNING SIGN
    print('warningValue $warningCircleValue');
    Color warningColor = Colors.white;
    PaintingStyle ps = PaintingStyle.stroke;

    if (warningCircleValue == 0.75) {
      // warningColor = Colors.green;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.5) {
      // warningColor = Colors.yellow;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.7) {
      warningColor = Colors.red;
      ps = PaintingStyle.fill;
    }

    final paintCircle = Paint()
      ..color = warningColor
      ..strokeWidth = 0
      ..style = ps
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(size.width + 100, -45), 20, paintCircle);

    const maxLabel2 = 'Max';
    final maxLabelSize2 = TextPainter(
      text: const TextSpan(text: maxLabel2),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize2.layout();
    maxLabelSize2.paint(canvas, Offset(size.width - 220, -45));

    const minLabel2 = 'Min';
    final minLabelSize2 = TextPainter(
      text: const TextSpan(text: minLabel2),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize2.layout();
    minLabelSize2.paint(canvas, Offset(size.width - 220, 5));

    String heartBeatLabel = 'Breathing $breathingRateDisplayValue bpm';
    final heartLabelSize = TextPainter(
      text: TextSpan(text: heartBeatLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    heartLabelSize.layout();
    heartLabelSize.paint(canvas, Offset(size.width - 150, -55));

    const zeroLabel2 = '0';
    final zeroLabelSize2 = TextPainter(
      text: const TextSpan(text: zeroLabel2),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize2.layout();
    zeroLabelSize2.paint(canvas, Offset(size.width - 220, -19));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BpVerticalLinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    canvas.drawLine(Offset(size.width - 220, -40),
        Offset(size.width - 220, size.height - 20), _paintLine);

    // WARNING SIGN
    print('warningValue $warningCircleValue');
    Color warningColor = Colors.white;
    PaintingStyle ps = PaintingStyle.stroke;

    if (warningCircleValue == 0.75) {
      // warningColor = Colors.green;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.5) {
      // warningColor = Colors.yellow;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.5) {
      warningColor = Colors.red;
      ps = PaintingStyle.fill;
    }

    final paintCircle = Paint()
      ..color = warningColor
      ..strokeWidth = 0
      ..style = ps
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(size.width + 100, -50), 20, paintCircle);

    const maxLabel3 = 'Max';
    final maxLabelSize3 = TextPainter(
      text: const TextSpan(text: maxLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize3.layout();
    maxLabelSize3.paint(canvas, Offset(size.width - 220, -43));
    const minLabel3 = 'Min';
    final minLabelSize3 = TextPainter(
      text: const TextSpan(text: minLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize3.layout();
    minLabelSize3.paint(canvas, Offset(size.width - 220, 5));

    String bloodPressureLabel =
        'Blood Pressure $bloodPressureDisplayValue mmHg';
    final bloodPressureLabelSize = TextPainter(
      text: TextSpan(text: bloodPressureLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    bloodPressureLabelSize.layout();
    bloodPressureLabelSize.paint(canvas, Offset(size.width - 150, -55));

    const zeroLabel3 = '0';
    final zeroLabelSize3 = TextPainter(
      text: const TextSpan(text: zeroLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize3.layout();
    zeroLabelSize3.paint(canvas, Offset(size.width - 220, -19));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class TempVerticalLinePainter extends CustomPainter {
  final Paint _paintLine = Paint()
    ..color = Colors.white
    ..strokeWidth = 1
    ..style = PaintingStyle.stroke
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, size) {
    canvas.drawLine(Offset(size.width - 220, -40),
        Offset(size.width - 220, size.height - 20), _paintLine);

    // WARNING SIGN
    print('warningValue $warningCircleValue');
    Color warningColor = Colors.white;
    PaintingStyle ps = PaintingStyle.stroke;

    if (warningCircleValue == 0.75) {
      // warningColor = Colors.green;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 0.5) {
      // warningColor = Colors.yellow;
      // ps = PaintingStyle.fill;
    }
    if (warningCircleValue == 1) {
      warningColor = Colors.red;
      ps = PaintingStyle.fill;
    }

    final paintCircle = Paint()
      ..color = warningColor
      ..strokeWidth = 0
      ..style = ps
      ..strokeJoin = StrokeJoin.round;

    canvas.drawCircle(Offset(size.width + 100, -55), 20, paintCircle);

    const maxLabel3 = 'Max';
    final maxLabelSize3 = TextPainter(
      text: const TextSpan(text: maxLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize3.layout();
    maxLabelSize3.paint(canvas, Offset(size.width - 220, -43));
    const minLabel3 = 'Min';
    final minLabelSize3 = TextPainter(
      text: const TextSpan(text: minLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize3.layout();
    minLabelSize3.paint(canvas, Offset(size.width - 220, 1));

    String temperatureLabel = 'Temperature $temperatureDisplayValue°C';
    final temperatureLabelSize = TextPainter(
      text: TextSpan(text: temperatureLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    temperatureLabelSize.layout();
    temperatureLabelSize.paint(canvas, Offset(size.width - 150, -55));

    const zeroLabel3 = '0';
    final zeroLabelSize3 = TextPainter(
      text: const TextSpan(text: zeroLabel3),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize3.layout();
    zeroLabelSize3.paint(canvas, Offset(size.width - 220, -19));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
