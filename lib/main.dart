import 'package:flutter/material.dart';
import 'emergencyNoLogin.dart';
import 'loginSignUp.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'homepage.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(const TravelSafe());

class TravelSafe extends StatefulWidget {
  const TravelSafe({Key? key}) : super(key: key);

  @override
  _TravelSafeState createState() => _TravelSafeState();
}

class _TravelSafeState extends State<TravelSafe> {
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "EmergencyOrLogin",
      debugShowCheckedModeBanner: false,
      home: EmergencyOrLogin(),
    );
  }
}

class EmergencyOrLogin extends StatefulWidget {
  const EmergencyOrLogin({Key? key}) : super(key: key);

  @override
  _EmergencyOrLoginState createState() => _EmergencyOrLoginState();
}

class _EmergencyOrLoginState extends State<EmergencyOrLogin> {
  SharedPreferences? _preferences; //using shared preferences for 'staying logged in'
  List<Map<String, dynamic>> _user = [];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete((){
      setState(() {});
    });
  }

  Future<void> initializePreference() async{
    _preferences = await SharedPreferences.getInstance();
    //await _preferences?.remove('username');
    var user_exists = _preferences?.getString('username');
    if(user_exists != null){
      _user =
      await DatabaseHelper.getUserByUsername(user_exists);
      String username = _user[0]['username'];
      String password = _user[0]['password'];
      String nickname = _user[0]['nickname'];
      int auto = _user[0]['autoLogin'];
      User userLogin = User(username, password, nickname, auto);
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => HomePage(user: userLogin)),
        ModalRoute.withName('/'),
      );
    }
  }

  void _submitEmergency() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const EmergencyNoLogin()),
      ModalRoute.withName('/'),
    );
  }

  void _submitLogin() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute<void>(
          builder: (BuildContext context) => const LoginSignUp()),
        ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("TravelSafe"),
        toolbarHeight: 40,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _submitLogin,
              child: Text(
                'Log In',
                style: Theme.of(context).textTheme.headline6,
              ),
            ),
          ]
        ),
      )
    );
  }
}
