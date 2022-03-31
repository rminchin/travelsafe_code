import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  final String username;
  const HomePage(
      {Key? key, required this.username})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
              automaticallyImplyLeading: false,
              title: const Text("Homepage")
          ),
        body: Column(
          children: [
            Text('Logged in as ${widget.username}')
          ]
        )
      ),
    );
  }
}
