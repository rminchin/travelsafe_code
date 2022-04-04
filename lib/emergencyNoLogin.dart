import 'package:flutter/material.dart';

class EmergencyNoLogin extends StatefulWidget {
  const EmergencyNoLogin(
      {Key? key})
      : super(key: key);

  @override
  EmergencyNoLoginState createState() => EmergencyNoLoginState();
}

class EmergencyNoLoginState extends State<EmergencyNoLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
          appBar: AppBar(
            centerTitle: true,
              title: const Text("Emergency")
          ),
          body: Center(
            child: Column(
                children: const [
                  Text('Emergency declared - no login details found!')
                ]
            ),
          )
      );
  }
}
