import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/colors.dart';
import '../../constants/custom_text.dart';
import 'sensors_test.dart';

class SensorsWaiting extends StatefulWidget {
  final String roomId;
  final String username;
  const SensorsWaiting({Key? key, required this.roomId, required this.username})
      : super(key: key);

  @override
  State<SensorsWaiting> createState() => _SensorsWaitingState();
}

class _SensorsWaitingState extends State<SensorsWaiting> {
  final db = FirebaseFirestore.instance;
  List<String> userlist = [];

  @override
  Widget build(BuildContext context) {
    db.collection("rooms").doc(widget.roomId).snapshots().listen(
      (event) {
        if (event.data()!['isStarted'] == true) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  SensorsTest(username: widget.username, roomId: widget.roomId),
            ),
          );
        }
      },
      onError: (error) => print("Listen failed: $error"),
    );

    return Container(
      color: active,
      padding: const EdgeInsets.fromLTRB(40, 260, 40, 260),
      child: Card(
        color: white,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: const CustomText(
                text: 'Waiting...',
                size: 28,
                weight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: StreamBuilder<Object>(
                  stream: db
                      .collection("rooms")
                      .doc(widget.roomId)
                      .collection('teams')
                      .doc('lz7q8nvBZ47pDVqfzOgR')
                      .collection('members')
                      .snapshots(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (!snapshot.hasData) {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: 1,
                          itemBuilder: (context, index) {
                            return Text(widget.username);
                          });
                    } else {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            print(snapshot.data.docs);
                            DocumentSnapshot doc = snapshot.data!.docs[index];
                            return Text(doc['username']);
                          });
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
