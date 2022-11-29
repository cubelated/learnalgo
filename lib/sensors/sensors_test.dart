import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:simple_kalman/simple_kalman.dart';
import 'package:oscilloscope/oscilloscope.dart';

class SensorsTest extends StatefulWidget {
  final String username;
  final String roomId;
  const SensorsTest({Key? key, required this.username, required this.roomId})
      : super(key: key);

  @override
  State<SensorsTest> createState() => _SensorsTestState();
}

final db = FirebaseFirestore.instance;

class _SensorsTestState extends State<SensorsTest> {
  List<double>? _accelerometerValues;
  List<double>? _userAccelerometerValues;
  List<double>? _gyroscopeValues;
  final _streamSubscriptions = <StreamSubscription<dynamic>>[];

  bool startCalculation = false;
  bool wait = false;
  int position = 1;
  int number = 1;

  double gyroInc = 0;

  List<double> traceXAcc = [];
  Oscilloscope? xUserAcc;
  List<double> traceYGyro = [];
  Oscilloscope? yGyro;
  List<double> kalmanYGyro = [];
  Oscilloscope? kalmanYGyroOsc;
  List<double> kalmanXAcc = [];
  Oscilloscope? kalmanXAccOsc;

  double sum = 0;
  String move = '';

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    // Check if phone is lifted
    if ((double.parse(gyroscope![0]).abs() > 0.2 ||
            double.parse(gyroscope[1]).abs() > 0.2) &&
        startCalculation == false) {
      startCalculation = true;
      gyroInc = 0;
      kalmanXAcc.clear();
      kalmanYGyro.clear();
      traceYGyro.clear();
      traceXAcc.clear();
      print('START calculation');
    }

    // Check if phone is placed
    if (double.parse(gyroscope[0]).abs() == 0 &&
        double.parse(gyroscope[1]).abs() == 0 &&
        double.parse(gyroscope[2]).abs() == 0 &&
        double.parse(accelerometer![2]).abs() >= 9.8 &&
        startCalculation == true) {
      startCalculation = false;

      //CALCULATE AUC to see the movement
      sum = kalmanXAcc.fold(0, (p, c) => p + c);
      print('Sum: $sum');

      //if positive == left
      if (sum >= 0.5) {
        move = 'Left';
        print('Move: Left');
      }

      //if negative == right
      if (sum <= -0.5) {
        move = 'Right';
        print('Move: Right');
      }

      print('STOP calculation');
    }

    // If lifted, save data and show to graph
    final xUserVal = _userAccelerometerValues![0];
    final yGyroVal = _gyroscopeValues![1];

    if (startCalculation == true) {
      gyroInc = gyroInc + yGyroVal;
      traceXAcc.add(xUserVal);
      traceYGyro.add(gyroInc);

      //using KALMAN FILTER for sudden and quick movements filter
      const alpha = 0.5;
      final kalman = SimpleKalman(errorMeasure: 10, errorEstimate: 10, q: 0.1);
      kalmanXAcc.add(kalman.filtered(xUserVal));

      xUserAcc = Oscilloscope(
        showYAxis: true,
        yAxisColor: Colors.orange,
        margin: const EdgeInsets.all(20.0),
        strokeWidth: 1.0,
        backgroundColor: Colors.black,
        traceColor: Colors.green,
        yAxisMax: 5.0,
        yAxisMin: -5.0,
        dataSet: traceXAcc,
      );
      yGyro = Oscilloscope(
        showYAxis: true,
        yAxisColor: Colors.orange,
        margin: const EdgeInsets.all(20.0),
        strokeWidth: 1.0,
        backgroundColor: Colors.black,
        traceColor: Colors.green,
        yAxisMax: 50.0,
        yAxisMin: -50.0,
        dataSet: traceYGyro,
      );
      kalmanXAccOsc = Oscilloscope(
        showYAxis: true,
        yAxisColor: Colors.orange,
        margin: const EdgeInsets.all(20.0),
        strokeWidth: 1.0,
        backgroundColor: Colors.black,
        traceColor: Colors.green,
        yAxisMax: 5.0,
        yAxisMin: -5.0,
        dataSet: kalmanXAcc,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sensor Example'),
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text('Move: $move'),
              Text('Sum: $sum'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
          // TextButton(
          //   onPressed: () {},
          //   style: TextButton.styleFrom(
          //     backgroundColor: active,
          //     disabledBackgroundColor: grey,
          //     shape: const RoundedRectangleBorder(
          //       borderRadius: BorderRadius.all(Radius.circular(10.0)),
          //     ),
          //   ),
          //   child: CustomText(
          //     text: 'In Position!',
          //     color: white,
          //     weight: FontWeight.bold,
          //     size: 14,
          //   ),
          // ),
          Expanded(child: xUserAcc ?? Container()),
          Expanded(child: yGyro ?? Container()),
          Expanded(child: kalmanXAccOsc ?? Container()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (final subscription in _streamSubscriptions) {
      subscription.cancel();
    }
  }

  @override
  void initState() {
    super.initState();
    _streamSubscriptions.add(
      accelerometerEvents.listen(
        (AccelerometerEvent event) {
          setState(() {
            _accelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      gyroscopeEvents.listen(
        (GyroscopeEvent event) {
          setState(() {
            _gyroscopeValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
    _streamSubscriptions.add(
      userAccelerometerEvents.listen(
        (UserAccelerometerEvent event) {
          setState(() {
            _userAccelerometerValues = <double>[event.x, event.y, event.z];
          });
        },
      ),
    );
  }
}
