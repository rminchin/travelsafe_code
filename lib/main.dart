import 'emergency/emergency_no_login.dart';
import 'helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/user.dart';
import 'screens/login_signup.dart';
import 'screens/homepage.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(); //call it before runApp()

  runApp(const TravelSafe());
}

class TravelSafe extends StatefulWidget {
  const TravelSafe({Key? key}) : super(key: key);

  @override
  _TravelSafeState createState() => _TravelSafeState();
}

class _TravelSafeState extends State<TravelSafe> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "EmergencyOrLogin",
      debugShowCheckedModeBanner: false,
      home: EmergencyOrLogin(loggedOut: 'n'),
    );
  }
}

class EmergencyOrLogin extends StatefulWidget {
  final String loggedOut;
  const EmergencyOrLogin({Key? key, required this.loggedOut}) : super(key: key);

  @override
  _EmergencyOrLoginState createState() => _EmergencyOrLoginState();
}

class _EmergencyOrLoginState extends State<EmergencyOrLogin> {
  SharedPreferences?
      _preferences; //using shared preferences for 'staying logged in'
  Map<String, dynamic> _user = {};

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
    //await _preferences?.remove('username');
    var userExists = _preferences?.getString('username');
    if (userExists != null && widget.loggedOut == 'n') {
      _user = await DatabaseHelper.getUserByUsernameFirebase(userExists);
      String username = _user['username'];
      String password = _user['password'];
      String nickname = _user['nickname'];
      User userLogin = User(username, password, nickname);
      globals.user = userLogin;
      Navigator.pushAndRemoveUntil<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const HomePage(tab: 2)),
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
          automaticallyImplyLeading: false,
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
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.redAccent),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitLogin,
                  child: Text(
                    'Log In or Sign Up',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
              ]),
        ));
  }
}
