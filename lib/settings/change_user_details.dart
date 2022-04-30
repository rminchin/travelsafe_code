import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../screens/homepage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dart:convert';

class ChangeUserDetails extends StatefulWidget {
  const ChangeUserDetails({Key? key}) : super(key: key);

  @override
  ChangeDetailsState createState() => ChangeDetailsState();
}

class ChangeDetailsState extends State<ChangeUserDetails> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _streams = [];
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
  }

  void _newUsername() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const NewUsername()));
  }

  void _newPassword() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const NewPassword()));
  }

  void _newNickname() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const NewNickname()));
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 4)),
      ModalRoute.withName('/'),
    );
  }

  void updateScreen() async {
    _requests =
        await DatabaseHelper.getRequestsReceivedFirebase(globals.user.username);
    _streams =
        await DatabaseHelper.getLiveStreamsFirebase(globals.user.username);
    _chats = await DatabaseHelper.getAllUnreadFirebase(globals.user.username);

    if (_requests.length > globals.requests.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New friend request!"),
      ));
    }

    if (_streams.length > globals.streams.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New livestream started!"),
      ));
    }

    if (_chats.length > globals.unread.length) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New message received!"),
      ));
    }

    if (mounted) {
      setState(() {
        globals.requests = _requests;
        globals.streams = _streams;
        globals.unread = _chats;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('allNotifications')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          updateScreen();
          return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text("TravelSafe"),
                  leading: BackButton(
                    color: Colors.white,
                    onPressed: _backScreen,
                  )),
              body: Center(
                child: Column(children: [
                  const Text('Change user details:'),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _newUsername,
                    child: Text(
                      'Change username',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _newPassword,
                    child: Text(
                      'Change password',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _newNickname,
                    child: Text(
                      'Change nickname',
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ]),
              ));
        });
  }
}

class NewUsername extends StatefulWidget {
  const NewUsername({Key? key}) : super(key: key);

  @override
  NewUsernameState createState() => NewUsernameState();
}

class NewPassword extends StatefulWidget {
  const NewPassword({Key? key}) : super(key: key);

  @override
  NewPasswordState createState() => NewPasswordState();
}

class NewNickname extends StatefulWidget {
  const NewNickname({Key? key}) : super(key: key);

  @override
  NewNicknameState createState() => NewNicknameState();
}

class NewUsernameState extends State<NewUsername> {
  final TextEditingController _controllerUsernameEdit = TextEditingController();
  String _usernameNew = '';

  final FocusNode _focusEdit = FocusNode();

  List<Map<String, dynamic>> _users = [];

  SharedPreferences?
      _preferences; //using shared preferences for 'staying logged in'

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
    _refreshUsers();
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
  }

  void _refreshUsers() async {
    final data = await DatabaseHelper.getUsersFirebase();
    if (mounted) {
      setState(() {
        _users = data;
      });
    }
  }

  void _submitChanges() async {
    if (isValidChange(_controllerUsernameEdit.text)) {
      var username = _controllerUsernameEdit.text;
      var password = globals.user.password;
      var nickname = globals.user.nickname;
      try {
        await DatabaseHelper.updateUserFirebase(
            globals.user.username, username, password, nickname);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully updated username!'),
        ));
        _refreshUsers();
        if (_preferences?.getString('username') == globals.user.username) {
          _preferences?.setString('username', username);
        }
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePage(tab: 4)),
          ModalRoute.withName('/'),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update username, please try again'),
        ));
      }
    } else {
      _controllerUsernameEdit.clear();
      _focusEdit.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid information entered, please try again'),
      ));
      if (mounted) {
        setState(() {
          _usernameNew = _controllerUsernameEdit.text;
        });
      }
    }
  }

  String returnMessageEdit(String text) {
    if (text.length < 6 && text.isNotEmpty) {
      return 'New username is too short';
    } else if (text.length > 20) {
      return 'New username is too long';
    } else if (usernameExists()) {
      return 'New username already exists';
    } else {
      return 'check';
    }
  }

  bool isValidChange(String text) {
    return (text.length >= 6 && text.length <= 20 && !usernameExists());
  }

  bool usernameExists() {
    var existingUser;
    try {
      existingUser = _users.firstWhere(
          (element) => element['username'] == _controllerUsernameEdit.text);
    } on StateError {
      existingUser = -1;
    }

    if (existingUser == -1 &&
        _controllerUsernameEdit.text != globals.user.username) {
      return false;
    } else {
      return true;
    }
  }

  @override
  void dispose() {
    _controllerUsernameEdit.dispose();
    _focusEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")),
        body: Center(
            child: Column(children: [
          const Text('Change username:'),
          const SizedBox(height: 30),
          TextFormField(
            controller: _controllerUsernameEdit,
            focusNode: _focusEdit,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Enter your new username',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              String text2 = returnMessageEdit(text!);
              if (text2 != 'check') {
                return text2;
              } else {
                return null;
              }
            },
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _usernameNew = _controllerUsernameEdit.text;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed: isValidChange(_usernameNew) ? _submitChanges : null,
            child: Text(
              'Confirm changes',
              style: Theme.of(context).textTheme.headline6,
            ),
            style: ButtonStyle(
              backgroundColor: isValidChange(_usernameNew)
                  ? MaterialStateProperty.all<Color>(Colors.blueAccent)
                  : MaterialStateProperty.all<Color>(Colors.grey),
            ),
          ),
        ])));
  }
}

class NewPasswordState extends State<NewPassword> {
  final TextEditingController _controllerPasswordOld = TextEditingController();
  final TextEditingController _controllerPasswordNew = TextEditingController();

  String _passwordOld = '';
  String _passwordNew = '';

  final FocusNode _focusEdit = FocusNode();

  Map<String, dynamic> _user = {};
  String _text2 = '';

  @override
  void initState() {
    super.initState();
  }

  bool _showPasswordEditNew = false;
  void _toggleVisibilityEditNew() {
    if (mounted) {
      setState(() {
        _showPasswordEditNew = !_showPasswordEditNew;
      });
    }
  }

  bool _showPasswordEditOld = false;
  void _toggleVisibilityEditOld() {
    if (mounted) {
      setState(() {
        _showPasswordEditOld = !_showPasswordEditOld;
      });
    }
  }

  void _submitChanges() async {
    if (isValidChange(_controllerPasswordOld.text) &&
        isValidChange(_controllerPasswordNew.text) &&
        await passwordMatches()) {
      var username = globals.user.username;
      var nickname = globals.user.nickname;

      var bytes = utf8.encode(_controllerPasswordNew.text);
      var digest = sha256.convert(bytes);

      try {
        await DatabaseHelper.updateUserFirebase(
            username, username, digest.toString(), nickname);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully updated password!'),
        ));
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePage(tab: 4)),
          ModalRoute.withName('/'),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update password, please try again'),
        ));
      }
    } else {
      _controllerPasswordOld.clear();
      _controllerPasswordNew.clear();
      _focusEdit.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid information entered, please try again'),
      ));
      if (mounted) {
        setState(() {
          _passwordOld = _controllerPasswordOld.text;
          _passwordNew = _controllerPasswordNew.text;
        });
      }
    }
  }

  Future<String> returnMessageEdit(String text) async {
    if (text.length < 6 && text.isNotEmpty) {
      return 'Too short';
    } else if (text.length > 20) {
      return 'Too long';
    } else if (!text.contains(RegExp(r'[0-9]')) && text.isNotEmpty) {
      return 'Must contain at least one number';
    } else if (!text.contains(RegExp(r'[!@#\$&*~]')) && text.isNotEmpty) {
      return 'Must contain at least one special character';
    } else if (await passwordMatches() == false) {
      return 'Incorrect password entered';
    } else {
      return 'check';
    }
  }

  String returnMessageEditNew(String text) {
    if (text.length < 6 && text.isNotEmpty) {
      return 'New password is too short';
    } else if (text.length > 20) {
      return 'New password is too long';
    } else if (!text.contains(RegExp(r'[0-9]')) && text.isNotEmpty) {
      return 'New password must contain at least one number';
    } else if (!text.contains(RegExp(r'[!@#\$&*~]')) && text.isNotEmpty) {
      return 'New password must contain at least one special character';
    } else {
      return 'check';
    }
  }

  bool isValidChange(String text) {
    return (text.length >= 6 &&
        text.length <= 20 &&
        text.contains(RegExp(r'[0-9]')) &&
        text.contains(RegExp(r'[!@#\$&*~]')));
  }

  Future<bool> passwordMatches() async {
    var bytes = utf8.encode(_controllerPasswordOld.text);
    var digest = sha256.convert(bytes); //hash password input

    _user =
        await DatabaseHelper.getUserByUsernameFirebase(globals.user.username);
    try {
      if (_user['password'] == digest.toString()) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _controllerPasswordOld.dispose();
    _controllerPasswordNew.dispose();
    _focusEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")),
        body: Center(
            child: Column(children: [
          const Text('Change Password:'),
          const SizedBox(height: 30),
          TextFormField(
            obscureText: !_showPasswordEditOld,
            controller: _controllerPasswordOld,
            focusNode: _focusEdit,
            autofocus: true,
            decoration: InputDecoration(
                labelText: 'Confirm your old password for security',
                suffixIcon: (GestureDetector(
                    onTap: () {
                      _toggleVisibilityEditOld();
                    },
                    child: Icon(_showPasswordEditOld
                        ? Icons.visibility
                        : Icons.visibility_off)))),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              if (_text2 != 'check') {
                return _text2;
              } else {
                return null;
              }
            },
            onChanged: (value) async {
              final text2 =
                  await returnMessageEdit(_controllerPasswordOld.text);
              if (mounted) {
                setState(() {
                  _text2 = text2;
                  _passwordOld = _controllerPasswordOld.text;
                });
              }
            },
          ),
          const SizedBox(height: 30),
          TextFormField(
            obscureText: !_showPasswordEditNew,
            controller: _controllerPasswordNew,
            decoration: InputDecoration(
                labelText: 'Enter your new password',
                suffixIcon: (GestureDetector(
                    onTap: () {
                      _toggleVisibilityEditNew();
                    },
                    child: Icon(_showPasswordEditNew
                        ? Icons.visibility
                        : Icons.visibility_off)))),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              String text2 = returnMessageEditNew(text!);
              if (text2 != 'check') {
                return text2;
              } else {
                return null;
              }
            },
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _passwordNew = _controllerPasswordNew.text;
                });
              }
            },
          ),
          ElevatedButton(
            onPressed:
                isValidChange(_passwordOld) && isValidChange(_passwordNew)
                    ? _submitChanges
                    : null,
            child: Text(
              'Confirm changes',
              style: Theme.of(context).textTheme.headline6,
            ),
            style: ButtonStyle(
              backgroundColor:
                  isValidChange(_passwordOld) && isValidChange(_passwordNew)
                      ? MaterialStateProperty.all<Color>(Colors.blueAccent)
                      : MaterialStateProperty.all<Color>(Colors.grey),
            ),
          ),
        ])));
  }
}

class NewNicknameState extends State<NewNickname> {
  final TextEditingController _controllerNicknameEdit = TextEditingController();
  String _nicknameNew = '';

  final FocusNode _focusEdit = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  void _submitChanges() async {
    if (isValidChange(_controllerNicknameEdit.text)) {
      var username = globals.user.username;
      var password = globals.user.password;
      var nickname = _controllerNicknameEdit.text;

      try {
        await DatabaseHelper.updateUserFirebase(
            username, username, password, nickname);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Successfully updated nickname!'),
        ));
        Navigator.pushAndRemoveUntil<void>(
          context,
          MaterialPageRoute<void>(
              builder: (BuildContext context) => const HomePage(tab: 4)),
          ModalRoute.withName('/'),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Failed to update nickname, please try again'),
        ));
      }
    } else {
      _controllerNicknameEdit.clear();
      _focusEdit.requestFocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid information entered, please try again'),
      ));
      if (mounted) {
        setState(() {
          _nicknameNew = _controllerNicknameEdit.text;
        });
      }
    }
  }

  String returnMessageEdit(String text) {
    if (text.length < 3 && text.isNotEmpty) {
      return 'New nickname is too short';
    } else if (text.length > 20) {
      return 'New nickname is too long';
    } else {
      return 'check';
    }
  }

  bool isValidChange(String text) {
    return (text.length >= 3 && text.length <= 20);
  }

  @override
  void dispose() {
    _controllerNicknameEdit.dispose();
    _focusEdit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")),
        body: Center(
            child: Column(children: [
          const Text('Change Nickname:'),
          const SizedBox(height: 30),
          TextFormField(
            controller: _controllerNicknameEdit,
            focusNode: _focusEdit,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Enter your new nickname',
            ),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (text) {
              String text2 = returnMessageEdit(text!);
              if (text2 != 'check') {
                return text2;
              } else {
                return null;
              }
            },
            onChanged: (value) {
              if (mounted) {
                setState(() {
                  _nicknameNew = _controllerNicknameEdit.text;
                });
              }
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: isValidChange(_nicknameNew) ? _submitChanges : null,
            child: Text(
              'Confirm changes',
              style: Theme.of(context).textTheme.headline6,
            ),
            style: ButtonStyle(
              backgroundColor: isValidChange(_nicknameNew)
                  ? MaterialStateProperty.all<Color>(Colors.blueAccent)
                  : MaterialStateProperty.all<Color>(Colors.grey),
            ),
          ),
        ])));
  }
}
