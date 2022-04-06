import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'package:travelsafe_v1/screens/login_signup.dart';
import 'change_user_details.dart';
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
    _value = false;
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
    var userFound = _preferences?.getString('username');
    setState(() {
      _value = userFound != null && userFound == widget.user.username;
    });
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

  void _changeUserDetails() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ChangeUserDetails(user: widget.user)));
  }

  updateUserAutoLogin() async {
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
                Text('${widget.user.nickname}\'s settings'),
                const SizedBox(height: 30),
                ListTile(
                  title: const Text("Automatically log in on this device:"),
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
                  onPressed: _changeUserDetails,
                  child: Text(
                    'Change User Details',
                    style: Theme.of(context).textTheme.headline6,
                  )
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
