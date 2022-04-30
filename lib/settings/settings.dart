import 'change_user_details.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/user.dart';
import '../screens/login_signup.dart';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  const Settings({Key? key}) : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late bool _value;
  SharedPreferences?
      _preferences; //using shared preferences for 'staying logged in'
  late bool _check;

  @override
  void initState() {
    super.initState();
    _value = false;
    _check = false;
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
    var userFound = _preferences?.getString('username');
    setState(() {
      _value = userFound != null && userFound == globals.user.username;
    });

    _check = await DatabaseHelper.checkLive(globals.user.username);
  }

  _submitLogout() async {
    globals.user = User('', '', '');
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully logged out'),
    ));
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginSignUp()));
  }

  void _changeUserDetails() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const ChangeUserDetails()));
  }

  updateUserAutoLogin() async {
    if (_value) {
      _preferences?.setString('username', globals.user.username);
    } else {
      _preferences?.remove('username');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: [
        Text('${globals.user.nickname}\'s settings'),
        const SizedBox(height: 30),
        ListTile(
          title: const Text("Automatically log in on this device:"),
          trailing: Checkbox(
            value: _value,
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _value = value!;
                  updateUserAutoLogin();
                });
              }
            },
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
            onPressed: _check ? null : _changeUserDetails,
            child: Text(
              'Change User Details',
              style: Theme.of(context).textTheme.headline6,
            )),
        const SizedBox(height: 30),
        ElevatedButton(
          onPressed: () => _submitLogout(),
          child: Text(
            'Log Out',
            style: Theme.of(context).textTheme.headline6,
          ),
        )
      ]),
    ));
  }
}
