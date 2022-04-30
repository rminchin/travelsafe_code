import '../helpers/globals.dart' as globals;

import 'package:flutter/material.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  EmergencyState createState() => EmergencyState();
}

class EmergencyState extends State<Emergency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("Emergency")),
        body: Center(
          child: Column(children: [
            Text('Emergency declared - logged in as ${globals.user.nickname}')
          ]),
        ));
  }
}
