import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'loginSignUp.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends StatefulWidget {
  final User user;
  const Settings(
      {Key? key, required this.user})
      : super(key: key);

  @override
  SettingsState createState() => SettingsState();
}

class SettingsState extends State<Settings> {
  late bool _value;
  SharedPreferences?
  _preferences; //using shared preferences for 'staying logged in'

  @override
  void initState() {
    super.initState();
    _value = widget.user.autoLogin == 1;
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  _submitLogout() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Successfully logged out'),
    ));
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginSignUp()));
  }

  updateUserAutoLogin() async {
    await DatabaseHelper.updateUserFirebase(widget.user.username, widget.user.password, widget.user.nickname, _value);
    if(_value){
      _preferences?.setString('username', widget.user.username);
    } else{
      _preferences?.remove('username');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
              children: [
                Text('Settings - logged in as ${widget.user.nickname}'),
                const SizedBox(height: 30),
                ListTile(
                  title: const Text("Auto log in feature:"),
                  trailing: Checkbox(
                    value: _value,
                    onChanged: (value) {
                      setState(() {
                        _value = value!;
                        updateUserAutoLogin();
                      });
                    },
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _submitLogout(),
                  child: Text(
                    'Log Out',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                )
              ]
          ),
        )
    );
  }
}
