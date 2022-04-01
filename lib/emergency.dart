import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

class Emergency extends StatefulWidget {
  final User user;
  const Emergency(
      {Key? key, required this.user})
      : super(key: key);

  @override
  EmergencyState createState() => EmergencyState();
}

class EmergencyState extends State<Emergency> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: const Text("Emergency")
        ),
        body: Center(
          child: Column(
              children: [
                Text('Emergency declared - logged in as ${widget.user.nickname}')
              ]
          ),
        )
    );
  }
}
