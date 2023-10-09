import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hospital_app/providers/directoryprovider.dart';
import 'package:hospital_app/providers/filesavingprovider.dart';
import 'package:provider/provider.dart';

class PatientRecordedDataGraph extends StatefulWidget {
  const PatientRecordedDataGraph({super.key});

  @override
  State<PatientRecordedDataGraph> createState() =>
      _PatientRecordedDataGraphState();
}

double portraitWidth = 0.0;
double portraitHeight = 0.0;
double landScapeWidth = 0.0;
double landScapeHeight = 0.0;

class _PatientRecordedDataGraphState extends State<PatientRecordedDataGraph> {
  final List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  IconData playIcon = Icons.play_arrow;
  IconData stopIcon = Icons.stop;
  IconData pauseIcon = Icons.pause;
  Color playIconColor = Colors.green; // Color for the Record icon
  Color stopIconColor = Colors.red;
  Color pauseIconColor = Colors.orange;

  bool isPlaying = false; // To control playing
  int elapsedSeconds = 0; // To display elapsed time in seconds
  int elapsedMinutes = 0; // To display elapsed time in minutes
  int elapsedHours = 0; // To display elapsed time in hours
  Timer? playTimer;

  late DataRepositoryModel _dataRepositoryModel;
  final List<FlSpot> heartdataList = [];
  final List<FlSpot> breathingDataList = [];
  final List<FlSpot> bpDataLlist = [];
  final List<String> tempDataList = [];
  List<double> numbers = [];
  List<double> recordedTimeList = [];
  List<int> recordedHeartBeatList = [];
  List<int> recordedBreathingRateList = [];
  List<List<dynamic>> csvTable = [];
  late DirectoryProviderModel _directoryProviderModel;
  late Timer dataTimer;
//  String dataToExtract = '';

  LineChartData heartLineRecordedChartData() {
    double maxYValue = 0.0; // Initialize the maximum Y-value to 0.

    // Find the maximum Y-value in heartdataList.
    for (FlSpot spot in heartdataList) {
      if (spot.y > maxYValue) {
        maxYValue = spot.y;
      }
    }
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
      minX: heartdataList.isNotEmpty
          ? heartdataList.first.x
          : 0, // Take note of these things
      maxX: heartdataList.isNotEmpty ? heartdataList.last.x : 1, // Take Note
      minY: 0, // Take Note
      maxY: 550, // Take Note
    );
  }

  LineChartData bpLineRecordedChartData() {
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

  LineChartData breathingLineRecordedChartData() {
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

  @override
  void initState() {
    super.initState();
    _dataRepositoryModel = DataRepositoryModel();
    _directoryProviderModel = DirectoryProviderModel();
    print(portraitHeight);
    print(portraitWidth);

    // getDataFile();
  }

  @override
  void dispose() {
    super.dispose();
    //_dataRepositoryModel.dispose();
    // _directoryProviderModel.dispose();
    //context.watch<DataRepositoryModel>().dispose();
    dataTimer.cancel();
    playTimer?.cancel();
  }

  void getDataFile() {
    // setState(() {
    _directoryProviderModel =
        Provider.of<DirectoryProviderModel>(context, listen: false);
    //print(_directoryProviderModel.listOfFilesNames2[index]);
    _dataRepositoryModel =
        Provider.of<DataRepositoryModel>(context, listen: false);
    // _dataRepositoryModel.loadData(_directoryProviderModel
    //   .listOfFilesNames2[_dataRepositoryModel.indexSelected]);

    _dataRepositoryModel.loadDataFromCsv(_directoryProviderModel
        .listOfFilesNames2[_dataRepositoryModel.indexSelected]);

    // print(_dataRepositoryModel.indexSelected);
    // });
    getHealthData();
    if (recordedHeartBeatList.length - 1 == heartdataList.length) {
      dataTimer.cancel();
      playTimer?.cancel();
    }
  }

  int counter = 0;
  int index = 0;
  void getHealthData() {
    try {
      csvTable = _dataRepositoryModel.csvTable;
      // row is changing and column
      // print(csvTable);
      print(csvTable[2][2]);
      for (int i = 1; i < csvTable.length; i++) {
        recordedTimeList.add(csvTable[i][0] / 1000000000000);
      }
      for (int i = 1; i < csvTable.length; i++) {
        recordedHeartBeatList.add(csvTable[i][1]);
        recordedBreathingRateList.add(int.parse(csvTable[i][2]));
      }
      //print(recordedBreathingRateList);

      const updateInterval = Duration(seconds: 1);
      dataTimer = Timer.periodic(updateInterval, (timer) {
        print('okay');
        index++;
        // print(index);
        setState(() {
          heartdataList.add(FlSpot(recordedTimeList[index],
              recordedHeartBeatList[index].toDouble()));
          //   print(heartdataList);
          breathingDataList.add(FlSpot(recordedTimeList[index],
              recordedBreathingRateList[index].toDouble()));
          if (heartdataList.length > 20) {
            heartdataList.removeAt(0);
          }
          if (breathingDataList.length > 20) {
            breathingDataList.removeAt(0);
          }
        });
        // print(heartdataList.length);

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
      });
    } catch (e) {
      print(e);
    }
  }

  void getBreathingData() {}

  @override
  Widget build(BuildContext context) {
    portraitWidth = MediaQuery.of(context).size.width;
    portraitHeight = MediaQuery.of(context).size.height;
    landScapeWidth = portraitWidth;
    landScapeHeight = portraitHeight;
    return Scaffold(
        appBar: AppBar(
          title: Text('Atlantis-UgarSoft'),
        ),
        body: Container(
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* Expanded(
              child: Text(
            context.watch<ConnectionProvider>().connect,
            style: const TextStyle(color: Colors.green),
          )),*/
              Expanded(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    height: 10,
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
                      // height: 30,
                      child: heartdataList.isNotEmpty
                          ? LineChart(
                              heartLineRecordedChartData(),
                            )
                          : Center(
                              child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2,
                              height: MediaQuery.of(context).size.height * 2,
                              child: CustomPaint(painter: LinePainter()),
                            ))),
                ),
              ),
              Expanded(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    height: 10,
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
                      //height: 30,
                      child: breathingDataList.isNotEmpty
                          ? LineChart(
                              breathingLineRecordedChartData(),
                            )
                          : Center(
                              child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2,
                              height: MediaQuery.of(context).size.height * 2,
                              child: CustomPaint(painter: LinePainter()),
                            ))),
                ),
              ),
              Expanded(
                child: SizedBox(
                    width: MediaQuery.of(context).size.width * 2,
                    height: 10,
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
                      // height: 50,
                      child: bpDataLlist.isNotEmpty
                          ? LineChart(
                              bpLineRecordedChartData(),
                            )
                          : Center(
                              child: SizedBox(
                              width: MediaQuery.of(context).size.width * 2,
                              height: MediaQuery.of(context).size.height * 2,
                              child: CustomPaint(painter: LinePainter()),
                            ))),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                      alignment: Alignment.topRight,
                      child: IconButton(
                        onPressed: () {
                          if (!isPlaying) {
                            // Start recording
                            setState(() {
                              isPlaying = true;
                            });
                            play();
                          } else {
                            // Pause recording
                            setState(() {
                              isPlaying = false;
                            });
                            // stop();
                            pause();
                          }
                        },
                        icon: Icon(
                          isPlaying ? pauseIcon : playIcon,
                          color: isPlaying ? Colors.orange : Colors.grey,
                          size: portraitWidth - 310,
                        ),
                      )),
                  IconButton(
                    onPressed: () {
                      if (isPlaying) {
                        // Stop recording
                        setState(() {
                          isPlaying = false;
                        });
                        stop();
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
              SizedBox(
                height: portraitWidth - 340,
              ),
              Text(
                '${elapsedHours.toString().padLeft(2, '0')}:${elapsedMinutes.toString().padLeft(2, '0')}:${elapsedSeconds.toString().padLeft(2, '0')}',
                style: const TextStyle(fontSize: 20, color: Colors.white),
              ),
              SizedBox(
                height: portraitHeight / 4,
              ),
              /*  Align(
              alignment: Alignment.bottomLeft,
              child: Text(
                'Temperature: $temperature2°C  Drip: $dripLevel%',
                style: const TextStyle(fontSize: 15, color: Colors.white),
              )),*/
              /*  Expanded(
              child: SizedBox(
            width: 5,
            child: CustomPaint(
              painter: TemperatureLevelPainter(
                  temperatureLevel, portraitWidth - 480, portraitHeight / 20),
            ),
          )),*/
              /* Expanded(
              child: SizedBox(
            height: 10,
            width: 5,
            child: CustomPaint(
              painter: DripLevelPainter(
                  dripLevel, portraitWidth - 370, landScapeHeight - 787),
            ),
          )),*/
            ],
          ),
        ));
  }

  void play() {
    // dataUpdateTimer?.cancel(); // Cancel any existing timer
    getDataFile();
    // Start a new timer for recording
    /*playTimer = Timer.periodic(Duration(seconds: 1), (_) {
      /*setState(() {
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
      });*/
    });*/
    setState(() {
      playIcon = Icons.play_arrow;
      playIconColor = pauseIconColor;
      pauseIcon = Icons.pause;
      pauseIconColor = Colors.green;
      stopIcon = Icons.stop;
      stopIconColor = Colors.red;
    });
  }

  void pause() {
    playTimer?.cancel();
    dataTimer.cancel();

    setState(() {
      isPlaying = false;
      playIcon = Icons.play_arrow;
      playIconColor = Colors.green;
      pauseIcon = Icons.pause;
      pauseIconColor = pauseIconColor;
      stopIcon = Icons.stop;
      stopIconColor = Colors.red;
    });
  }

  void stop() {
    playTimer?.cancel();
    dataTimer.cancel();
    setState(() {
      elapsedHours = 0;
      elapsedMinutes = 0;
      elapsedSeconds = 0;
      isPlaying = false;
      playIcon = Icons.play_arrow;
      playIconColor = Colors.green;
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
    canvas.drawLine(Offset(0, portraitHeight / 50),
        Offset(portraitHeight, portraitHeight / 50), _paintLine);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
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
    // print(size.height);
    canvas.drawLine(Offset(portraitHeight - 835, portraitHeight / 14),
        Offset(portraitHeight - 835, portraitHeight / 5.5), _paintLine);

    const maxLabel = 'Max';
    final maxLabelSize = TextPainter(
      text: const TextSpan(text: maxLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize.layout();
    maxLabelSize.paint(
        canvas, Offset(portraitHeight - 843, portraitWidth / 10));

    const minLabel = 'Min';
    final minLabelSize = TextPainter(
      text: const TextSpan(text: minLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize.layout();
    minLabelSize.paint(
        canvas, Offset(portraitHeight - 843, portraitWidth / 2.8));

    const zeroLabel = '0';
    final zeroLabelSize = TextPainter(
      text: const TextSpan(text: zeroLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize.layout();
    zeroLabelSize.paint(
        canvas, Offset(portraitHeight - 839, portraitWidth / 4.3));
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
    // print(size.height);
    canvas.drawLine(Offset(portraitHeight - 835, portraitHeight / 20),
        Offset(portraitHeight - 835, portraitHeight / 6), _paintLine);

    const maxLabel = 'Max';
    final maxLabelSize = TextPainter(
      text: const TextSpan(text: maxLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize.layout();
    maxLabelSize.paint(
        canvas, Offset(portraitHeight - 843, portraitWidth / 18));

    const minLabel = 'Min';
    final minLabelSize = TextPainter(
      text: const TextSpan(text: minLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize.layout();
    minLabelSize.paint(canvas, Offset(portraitHeight - 843, portraitWidth / 3));

    const zeroLabel = '0';
    final zeroLabelSize = TextPainter(
      text: const TextSpan(text: zeroLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize.layout();
    zeroLabelSize.paint(
        canvas, Offset(portraitHeight - 839, portraitWidth / 5));
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
    // print(size.height);
    canvas.drawLine(Offset(portraitHeight - 835, portraitHeight - 680),
        Offset(portraitHeight - 835, portraitHeight / 6), _paintLine);

    const maxLabel = 'Max';
    final maxLabelSize = TextPainter(
      text: const TextSpan(text: maxLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    maxLabelSize.layout();
    maxLabelSize.paint(
        canvas, Offset(portraitHeight - 843, portraitHeight - 700));

    const minLabel = 'Min';
    final minLabelSize = TextPainter(
      text: const TextSpan(text: minLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    minLabelSize.layout();
    minLabelSize.paint(canvas, Offset(portraitHeight - 843, portraitWidth / 3));

    const zeroLabel = '0';
    final zeroLabelSize = TextPainter(
      text: const TextSpan(text: zeroLabel),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );
    zeroLabelSize.layout();
    zeroLabelSize.paint(
        canvas, Offset(portraitHeight - 839, portraitWidth / 5.5));
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

    Color waterColor;

    // Determine water color based on line position
    if (dripLevel >= 0.75) {
      waterColor = Colors.green;
    } else if (dripLevel < 0.6) {
      waterColor = Colors.yellow;
    } else {
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
