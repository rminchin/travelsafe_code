import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

import 'emergency.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage(
      {Key? key, required this.user})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  void _submitEmergency() {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => Emergency(user: widget.user))
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        extendBody: true,
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Homepage")
          ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Logged in as ${widget.user.nickname}'),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitEmergency,
                child: Text(
                  'Emergency',
                  style: Theme.of(context).textTheme.headline6,
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.redAccent),
                ),
              ),
            ]
          ),
        )
      ),
    );
  }
}
