import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sensor_test/sensors/sensors_waiting.dart';
import '../../constants/colors.dart';
import '../../constants/custom_text.dart';

class SensorsLobby extends StatefulWidget {
  const SensorsLobby({Key? key}) : super(key: key);

  @override
  State<SensorsLobby> createState() => _SensorsLobbyState();
}

class _SensorsLobbyState extends State<SensorsLobby> {
  final _formKey = GlobalKey<FormState>();

  final roomCode = TextEditingController();
  final userName = TextEditingController();
  final db = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: active,
      padding: const EdgeInsets.fromLTRB(40, 255, 40, 255),
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
                text: 'Room Code',
                size: 28,
                weight: FontWeight.bold,
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: userName,
                        style: const TextStyle(fontSize: 12),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: grey, width: 0.5)),
                          border: const OutlineInputBorder(),
                          hintText: 'Enter a username',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 10,),
                      TextFormField(
                        controller: roomCode,
                        style: const TextStyle(fontSize: 12),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid room code';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: grey, width: 0.5)),
                          border: const OutlineInputBorder(),
                          hintText: 'Enter a room code',
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  )),
            ),
            const SizedBox(
              height: 10,
            ),
            TextButton(
              onPressed: () => submit(),
              style: TextButton.styleFrom(
                backgroundColor: active,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
              child: CustomText(
                text: 'Submit',
                color: white,
                weight: FontWeight.bold,
                size: 14,
              ),
            )
          ],
        ),
      ),
    );
  }

  void submit() async {
    const snackBar = SnackBar(
      content: Text('Error occured.'),
    );

    //Check for room with input code
    final docRef =
        db.collection("rooms").where('code', isEqualTo: roomCode.text);
    docRef.get().then((res) async {
      //If exist
      if (res.docs.isNotEmpty) {
        int position = 0;
        List<int> numbers = [];

        //Check for generated set of numbers or generate numbers
        await db
            .collection("rooms")
            .doc(res.docs.first.id)
            .collection('teams')
            .doc('lz7q8nvBZ47pDVqfzOgR')
            .get()
            .then((value) {
          if (value.data()!['set'] != null) {
            print(value.data()!['set']);
            numbers = value.data()!['set'].cast<int>();
          } else {
            numbers = List.generate(10, (int index) => index);
            numbers.shuffle();
          }
        });

        //Upload to Firestore
        await db
            .collection("rooms")
            .doc(res.docs.first.id)
            .collection('teams')
            .doc('lz7q8nvBZ47pDVqfzOgR')
            .set({'no': 1, 'set': numbers}, SetOptions(merge: true)).then((value) => {});

        print('Created $numbers');

        //Check total amount of members and get member data
        await db
            .collection("rooms")
            .doc(res.docs.first.id)
            .collection('teams')
            .doc('lz7q8nvBZ47pDVqfzOgR')
            .collection('members')
            .get()
            .then((value) => {position = value.docs.length});
        
        final data = {
          "username": userName.text,
          "number": numbers.elementAt(position),
          "position": position + 1,
          'moving': false
        };
        print(data);

        //Add data to Firestore
        db
            .collection("rooms")
            .doc(res.docs.first.id)
            .collection('teams')
            .doc('lz7q8nvBZ47pDVqfzOgR')
            .collection('members')
            .add(data)
            .then((documentSnapshot) =>
                print("Added Data with ID: ${documentSnapshot.id}"));

        //Next page
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SensorsWaiting(roomId: res.docs.first.id, username: userName.text),
          ),
        );

        //If room code does not exist
      } else {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const CustomText(
                    text: 'Failed!',
                    weight: FontWeight.bold,
                    size: 18,
                  ),
                  content: const CustomText(text: 'Invalid room code!'),
                  actions: [
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: CustomText(
                          text: 'Okay',
                          color: active,
                          weight: FontWeight.bold,
                          size: 14,
                        ))
                  ],
                ));
      }
    }, onError: (e) => ScaffoldMessenger.of(context).showSnackBar(snackBar));
  }
}
