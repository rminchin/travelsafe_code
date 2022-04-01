import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage(
      {Key? key, required this.user})
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
            Text('Logged in as ${widget.user.nickname}')
          ]
        )
      ),
    );
  }
}
