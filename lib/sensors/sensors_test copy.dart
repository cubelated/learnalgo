import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
// import 'package:simple_kalman/simple_kalman.dart';
import '../../constants/colors.dart';
import '../constants/custom_text.dart';

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

  int number = 0;
  int position = 0;
  int opposeNumber = 0;

  bool toPrint = false;
  String? motion;
  String? movement;
  double xValue = 0;

  bool gettingData = false;
  bool isStarted = false;
  bool isMoving = false;
  List<double> data = [];
  List<double> startPos = [];
  List<List<double>> dataAcc = [];
  String? memberId;

  void loadData() async {
    final dbMember = db
        .collection("rooms")
        .doc(widget.roomId)
        .collection('teams')
        .doc('lz7q8nvBZ47pDVqfzOgR')
        .collection('members');
    dbMember.where('username', isEqualTo: widget.username).get().then((value) {
      memberId = value.docs.first.id;
      number = value.docs.first.data()['number'];
      position = value.docs.first.data()['position'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final accelerometer =
        _accelerometerValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final gyroscope =
        _gyroscopeValues?.map((double v) => v.toStringAsFixed(1)).toList();
    final userAccelerometer = _userAccelerometerValues
        ?.map((double v) => v.toStringAsFixed(1))
        .toList();

    final xUserVal = double.parse(userAccelerometer![0]);

    if (isStarted == true) {
      //start getting data when userAccelerometer != 0
      dataAcc.add(accelerometer!.map((String v) => double.parse(v)).toList());

      if (xUserVal.abs() > 0.1 && isMoving == false) {
        isMoving = true;
        db
            .collection("rooms")
            .doc(widget.roomId)
            .collection('teams')
            .doc('lz7q8nvBZ47pDVqfzOgR')
            .collection('members')
            .doc(memberId)
            .set({'moving': true}, SetOptions(merge: true)).then((value) {
          db
              .collection("rooms")
              .doc(widget.roomId)
              .collection('teams')
              .doc('lz7q8nvBZ47pDVqfzOgR')
              .collection('members')
              .where('moving', isEqualTo: true)
              .where('username', isNotEqualTo: widget.username)
              .snapshots()
              .listen((event) async {
                print(opposeNumber);
                print(number);
            opposeNumber = event.docs.first.data()['number'];
            await db
                .collection("rooms")
                .doc(widget.roomId)
                .collection('teams')
                .doc('lz7q8nvBZ47pDVqfzOgR')
                .collection('members')
                .doc(event.docs.first.id)
                .set({'number': number}, SetOptions(merge: true));
            number = opposeNumber;
            await db
                .collection("rooms")
                .doc(widget.roomId)
                .collection('teams')
                .doc('lz7q8nvBZ47pDVqfzOgR')
                .collection('members')
                .doc(memberId)
                .set({'number': opposeNumber}, SetOptions(merge: true));
          });
          setState(() {
            gettingData = true;
          });
        });
      }

      //end getting data when accelerometer is same as start for 5 builds
      if (dataAcc.length > 5 && isMoving == true) {
        if (dataAcc.elementAt(dataAcc.length - 5)[0] <= startPos[0] + 1 &&
            dataAcc.elementAt(dataAcc.length - 5)[0] >= startPos[0] - 1 &&
            dataAcc.elementAt(dataAcc.length - 5)[1] <= startPos[1] + 1 &&
            dataAcc.elementAt(dataAcc.length - 5)[1] >= startPos[1] - 1 &&
            dataAcc.elementAt(dataAcc.length - 5)[2] <= startPos[2] + 1 &&
            dataAcc.elementAt(dataAcc.length - 5)[2] >= startPos[2] - 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[0] <= startPos[0] + 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[0] >= startPos[0] - 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[1] <= startPos[1] + 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[1] >= startPos[1] - 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[2] <= startPos[2] + 1 &&
            dataAcc.elementAt(dataAcc.length - 4)[2] >= startPos[2] - 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[0] <= startPos[0] + 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[0] >= startPos[0] - 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[1] <= startPos[1] + 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[1] >= startPos[1] - 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[2] <= startPos[2] + 1 &&
            dataAcc.elementAt(dataAcc.length - 3)[2] >= startPos[2] - 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[0] <= startPos[0] + 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[0] >= startPos[0] - 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[1] <= startPos[1] + 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[1] >= startPos[1] - 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[2] <= startPos[2] + 1 &&
            dataAcc.elementAt(dataAcc.length - 2)[2] >= startPos[2] - 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[0] <= startPos[0] + 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[0] >= startPos[0] - 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[1] <= startPos[1] + 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[1] >= startPos[1] - 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[2] <= startPos[2] + 1 &&
            dataAcc.elementAt(dataAcc.length - 1)[2] >= startPos[2] - 1 &&
            gettingData == true) {
          setState(() async {
            db
                .collection("rooms")
                .doc(widget.roomId)
                .collection('teams')
                .doc('lz7q8nvBZ47pDVqfzOgR')
                .collection('members')
                .doc(memberId)
                .set({'moving': false}, SetOptions(merge: true));
            gettingData = false;
            isMoving = false;
          });
        }
      }
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
              Text('Position: $position'),
              Text('Number: $number'),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Accelerometer: $accelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('UserAccelerometer: $userAccelerometer'),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Gyroscope: $gyroscope'),
              ],
            ),
          ),
          TextButton(
            onPressed: isStarted ? null : () => setStartPos(),
            style: TextButton.styleFrom(
              backgroundColor: active,
              disabledBackgroundColor: grey,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0)),
              ),
            ),
            child: CustomText(
              text: 'In Position!',
              color: white,
              weight: FontWeight.bold,
              size: 14,
            ),
          ),
          CustomText(text: 'Movement: $movement'),
        ],
      ),
    );
  }

  void setStartPos() {
    setState(() {
      isStarted = true;
      startPos = _accelerometerValues!
          .map((e) => double.parse(e.toStringAsFixed(1)))
          .toList();
      print('Start Position : $startPos');
    });
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
    loadData();
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
