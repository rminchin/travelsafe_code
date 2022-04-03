import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:travelsafe_v1/helpers/user.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'homepage.dart';
import 'main.dart';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginSignUp extends StatefulWidget {
  const LoginSignUp({Key? key}) : super(key: key);

  @override
  _LoginSignUpState createState() => _LoginSignUpState();
}

class _LoginSignUpState extends State<LoginSignUp>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controllerUsername = TextEditingController();
  final TextEditingController _controllerUsernameLogin =
      TextEditingController();
  String _username = '';

  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerPasswordLogin =
      TextEditingController();
  String _password = '';

  final TextEditingController _controllerNickname = TextEditingController();
  String _nickname = '';

  final FocusNode _focusLogin = FocusNode();
  final FocusNode _focusSignup = FocusNode();

  late final TabController _controller = TabController(length: 2, vsync: this);

  bool _value = false;

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _user = [];

  SharedPreferences?
      _preferences; //using shared preferences for 'staying logged in'

  void _refreshUsers() async {
    final data = await DatabaseHelper.getUsers();
    print(data.length);
    print(data);
    setState(() {
      _users = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTabSelection);
    initializePreference().whenComplete(() {
      setState(() {});
    });
    _refreshUsers();
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  void _handleTabSelection() {
    if (_controller.indexIsChanging) {
      switch (_controller.index) {
        case 0:
          _focusLogin.requestFocus();
          _controllerUsername.clear();
          _controllerPassword.clear();
          _controllerNickname.clear();
          setState(() {
            _username = _controllerUsernameLogin.text;
            _password = _controllerPasswordLogin.text;
            _nickname = _controllerNickname.text;
            _value = false;
          });
          break;
        case 1:
          _focusSignup.requestFocus();
          _controllerUsernameLogin.clear();
          _controllerPasswordLogin.clear();
          setState(() {
            _username = _controllerUsername.text;
            _password = _controllerPassword.text;
            _nickname = _controllerNickname.text;
            _value = false;
          });
          break;
      }
    }
  }

  bool _showPasswordLogin = false;
  bool _showPasswordSignup = false;
  void _toggleVisibilitySignup() {
    setState(() {
      _showPasswordSignup = !_showPasswordSignup;
    });
  }

  void _toggleVisibilityLogin() {
    setState(() {
      _showPasswordLogin = !_showPasswordLogin;
    });
  }

  void _submitSignup() async {
    if (isValidSignup("u", _controllerUsername.text) &&
        isValidSignup("p", _controllerPassword.text) &&
        isValidSignup("n", _controllerNickname.text)) {
      var bytes = utf8.encode(_controllerPassword.text);
      var digest = sha256.convert(bytes); //hash password

      var user = User(_controllerUsername.text, digest.toString(),
          _controllerNickname.text, _value ? 1 : 0);
      if (_value == true) {
        _preferences = await SharedPreferences.getInstance();
        _preferences?.setString("username", _controllerUsername.text);
      }
      await DatabaseHelper.createUser(user);
      try {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully created an account!'),
        ));
        _refreshUsers();
        String username = _controllerUsername.text;
        String password = _controllerPassword.text;
        String nickname = _controllerNickname.text;
        int auto = _value ? 1 : 0;
        User userLogin = User(username, password, nickname, auto);
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => HomePage(user: userLogin)),
          ModalRoute.withName('/'),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Account creation failed, please try again'),
        ));
      }
    } else {
      _controllerUsername.clear();
      _controllerPassword.clear();
      _controllerNickname.clear();
      _focusSignup.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid signup credentials, please try again'),
      ));
      setState(() {
        _username = _controllerUsername.text;
        _password = _controllerPassword.text;
        _nickname = _controllerNickname.text;
      });
    }
  }

  void _submitLogin() async {
    var bytes = utf8.encode(_controllerPasswordLogin.text);
    var digest = sha256.convert(bytes); //hash password input

    _user =
        await DatabaseHelper.getUserByUsername(_controllerUsernameLogin.text);
    try {
      if (_user[0]['password'] == digest.toString()) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully logged in!'),
        ));
        _refreshUsers();
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
      } else {
        _controllerUsernameLogin.clear();
        _controllerPasswordLogin.clear();
        _focusLogin.requestFocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Invalid login credentials, please try again'),
        ));
      }
    } catch (e) {
      //in case SQL query fails somehow
      _controllerUsernameLogin.clear();
      _controllerPasswordLogin.clear();
      _focusLogin.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid login credentials, please try again'),
      ));
      setState(() {
        _username = _controllerUsernameLogin.text;
        _password = _controllerPasswordLogin.text;
      });
    }
  }

  bool isValidSignup(String mode, String text) {
    if (mode == "u") {
      return (text.length >= 6 && text.length <= 20);
    } else if (mode == "p") {
      return (text.length >= 6 &&
          text.length <= 20 &&
          text.contains(RegExp(r'[0-9]')) &&
          text.contains(RegExp(r'[!@#\$&*~]')));
    } else {
      return (text.length >= 3 && text.length <= 20);
    }
  }

  bool isValidLogin(String mode, String text) {
    return text.isNotEmpty;
  }

  bool usernameExists(String username) {
    var existingUser;
    try {
      existingUser = _users.firstWhere(
          (element) => element['username'] == _controllerUsername.text);
    } on StateError {
      existingUser = -1;
    }

    if (existingUser == -1) {
      return false;
    } else {
      return true;
    }
  }

  String returnMessageSignup(String mode, String text) {
    if (mode == "u_mess") {
      if (text.length < 6 && text.isNotEmpty) {
        return 'Username is too short';
      } else if (text.length > 20) {
        return 'Username is too long';
      } else if (usernameExists(text)) {
        return 'This username is already taken';
      } else {
        return 'check';
      }
    } else if (mode == "u_pass") {
      if (text.length < 6) {
        return 'Password is too short';
      } else if (text.length > 20) {
        return 'Password is too long';
      } else if (!text.contains(RegExp(r'[0-9]'))) {
        return 'Password must contain at least one number';
      } else if (!text.contains(RegExp(r'[!@#\$&*~]'))) {
        return 'Password must contain at least one special character';
      } else {
        return 'check';
      }
    } else {
      if (text.length < 3 && text.isNotEmpty) {
        return 'Nickname is too short';
      } else if (text.length > 20) {
        return 'Nickname is too long';
      } else {
        return 'check';
      }
    }
  }

  @override
  void dispose() {
    _controllerUsername.dispose();
    _controllerPassword.dispose();
    _controllerNickname.dispose();
    _controllerUsernameLogin.dispose();
    _controllerPasswordLogin.dispose();
    _focusLogin.dispose();
    _focusSignup.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _backScreen() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const EmergencyOrLogin(loggedOut: 'y')));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text("TravelSafe"),
              toolbarHeight: 40,
              leading: BackButton(
                color: Colors.white,
                onPressed: _backScreen,
              ),
              bottom: TabBar(controller: _controller, tabs: const [
                Tab(
                    icon: Icon(Icons.login),
                    child: Text("Click here to log in"),
                    height: 55),
                Tab(
                    icon: Icon(Icons.format_list_bulleted),
                    child: Text("Click here to sign up"),
                    height: 55)
              ]),
            ),
            body: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _controller,
                children: [
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),
                        const Text("Enter your details here to log in:",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            )),
                        const SizedBox(height: 30),
                        TextFormField(
                            autofocus: true,
                            focusNode: _focusLogin,
                            controller: _controllerUsernameLogin,
                            decoration: const InputDecoration(
                                labelText: 'Enter your username'),
                            autovalidateMode: AutovalidateMode.always,
                            onChanged: (value) {
                              setState(() {
                                _username = _controllerUsernameLogin.text;
                              });
                            }),
                        const SizedBox(height: 30),
                        TextFormField(
                          obscureText: !_showPasswordLogin,
                          controller: _controllerPasswordLogin,
                          decoration: InputDecoration(
                              labelText: 'Enter your password',
                              suffixIcon: (GestureDetector(
                                  onTap: () {
                                    _toggleVisibilityLogin();
                                  },
                                  child: Icon(_showPasswordLogin
                                      ? Icons.visibility
                                      : Icons.visibility_off)))),
                          autovalidateMode: AutovalidateMode.always,
                          onChanged: (value) {
                            setState(() {
                              _password = _controllerPasswordLogin.text;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 50,
                        ),
                        ElevatedButton(
                          // only enable the button if all inputs are valid
                          onPressed: isValidLogin("u", _username) &&
                                  isValidLogin("p", _password)
                              ? _submitLogin
                              : null,
                          child: Text(
                            'Log In',
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          //changes colour of button to further highlight valid/invalid input
                          style: ButtonStyle(
                            backgroundColor: isValidLogin("u", _username) &&
                                    isValidLogin("p", _password)
                                ? MaterialStateProperty.all<Color>(
                                    Colors.blueAccent)
                                : MaterialStateProperty.all<Color>(Colors.grey),
                          ),
                        ),
                      ]),
                  //////////////////////////////////////////////////////////////////////////////////////////////////////
                  Scrollbar(
                    thickness: 10,
                    radius: const Radius.elliptical(5, 5),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          const Text(
                              "Enter your details here to sign up for a new account:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _controllerUsername,
                            focusNode: _focusSignup,
                            decoration: const InputDecoration(
                              labelText: 'Enter your desired username',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              String text2 = returnMessageSignup('u_mess', text!);
                              if (text2 != 'check') {
                                return text2;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                _username = _controllerUsername.text;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            obscureText: !_showPasswordSignup,
                            controller: _controllerPassword,
                            decoration: InputDecoration(
                                labelText: 'Enter your desired password',
                                suffixIcon: (GestureDetector(
                                    onTap: () {
                                      _toggleVisibilitySignup();
                                    },
                                    child: Icon(_showPasswordSignup
                                        ? Icons.visibility
                                        : Icons.visibility_off)))),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              String text2 = returnMessageSignup('u_pass', text!);
                              if (text2 != 'check') {
                                return text2;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                _password = _controllerPassword.text;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _controllerNickname,
                            decoration: const InputDecoration(
                              labelText: 'Enter your desired nickname',
                            ),
                            autovalidateMode: AutovalidateMode.onUserInteraction,
                            validator: (text) {
                              String text2 = returnMessageSignup('u_nick', text!);
                              if (text2 != 'check') {
                                return text2;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                _nickname = _controllerNickname.text;
                              });
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ListTile(
                            title: const Text(
                                "Automatically log in each time you use the app:"),
                            trailing: Checkbox(
                              value: _value,
                              onChanged: (value) {
                                setState(() {
                                  _value = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 50),
                          ElevatedButton(
                            // only enable the button if all inputs are valid
                            onPressed: isValidSignup("u", _username) &&
                                    isValidSignup("p", _password) &&
                                    isValidSignup("n", _nickname)
                                ? _submitSignup
                                : null,
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            //changes colour of button to further highlight valid/invalid input
                            style: ButtonStyle(
                              backgroundColor: isValidSignup("u", _username) &&
                                      isValidSignup("p", _password) &&
                                      isValidSignup("n", _nickname)
                                  ? MaterialStateProperty.all<Color>(
                                      Colors.blueAccent)
                                  : MaterialStateProperty.all<Color>(Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ])),
      ),
    );
  }
}
