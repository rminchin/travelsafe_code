import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'emergency.dart';
import 'loginSignUp.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';

class HomePage extends StatefulWidget {
  final User user;
  const HomePage({Key? key, required this.user}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _alertValue = false;
  SharedPreferences?
      _preferences; //using shared preferences for 'staying logged in'

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete((){
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  void _submitEmergency() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => Emergency(user: widget.user)));
  }

  _submitLogoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Log out"),
          content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return ListTile(
                title: const Text("Tick this box if you no longer wish to automatically log in when opening the app"),
                trailing: Checkbox(
                  value: _alertValue,
                  onChanged: (value) {
                    setState(() {
                      _alertValue = value!;
                    });
                  },
                ),
              );
          }),
          actions: [
            TextButton(
              child: const Text("Log Out"),
              onPressed: () {
                _alertValue ? _submitLogout('yes') : _submitLogout('');
              },
            )
          ],
          elevation: 5,
        );
      },
    );
  }

  _submitLogout(String toDo) async {
    if (toDo != '') {
      await _preferences?.remove('username');
      await DatabaseHelper.updateUser(widget.user.username, widget.user.password, widget.user.nickname, false);
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully logged out'),
    ));
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginSignUp()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          extendBody: true,
          appBar: AppBar(
              automaticallyImplyLeading: false, title: const Text("Homepage")),
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
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.redAccent),
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () =>
                    _preferences != null
                        ? _submitLogoutAlert(context)
                        : _submitLogout(''),
                    child: Text(
                      'Log Out',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  )
                ]),
          )),
    );
  }
}
