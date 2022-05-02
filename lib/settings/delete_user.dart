import 'package:travelsafe_v1/screens/login_signup.dart';

import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../screens/homepage.dart';

import 'package:flutter/material.dart';

class DeleteUser extends StatefulWidget {
  const DeleteUser({Key? key}) : super(key: key);

  @override
  DeleteUserState createState() => DeleteUserState();
}

class DeleteUserState extends State<DeleteUser> {
  @override
  void initState() {
    super.initState();
  }

  void _deny() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 4)),
      ModalRoute.withName('/'),
    );
  }

  void _confirm() async {
    await DatabaseHelper.deleteUserFirebase(globals.user.username);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Account deleted successfully"),
    ));
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const LoginSignUp()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("TravelSafe"),
            leading: BackButton(
              color: Colors.white,
              onPressed: _deny,
            )),
        body: Center(
          child: Column(children: [
            const Text(
                'Sorry to see you go! Press Confirm to continue or Deny to stop the deletion'),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _deny,
              child: Text(
                'Deny',
                style: Theme.of(context).textTheme.headline6,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.redAccent),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _confirm,
              child: Text(
                'Confirm',
                style: Theme.of(context).textTheme.headline6,
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.greenAccent),
              ),
            ),
          ]),
        ));
  }
}
