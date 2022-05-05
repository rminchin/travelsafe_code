import '../emergency/play_alarm.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/notification_handler.dart';
import '../screens/homepage.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:url_launcher/url_launcher.dart';

class Emergency extends StatefulWidget {
  const Emergency({Key? key}) : super(key: key);

  @override
  EmergencyState createState() => EmergencyState();
}

class SetEmergencyNumberLogin extends StatefulWidget {
  const SetEmergencyNumberLogin({Key? key}) : super(key: key);

  @override
  SetEmergencyNumberLoginState createState() => SetEmergencyNumberLoginState();
}

class SendAlert extends StatefulWidget {
  const SendAlert({Key? key}) : super(key: key);

  @override
  SendAlertState createState() => SendAlertState();
}

class EmergencyState extends State<Emergency> {
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _saved = await DatabaseHelper.isEmergencyNumberSavedFirebase(
        globals.user.username);
  }

  void _setEmergency() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                const SetEmergencyNumberLogin()));
  }

  void _dialEmergency() async {
    String s =
        await DatabaseHelper.getEmergencyNumberFirebase(globals.user.username);
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: s,
    );
    await launchUrl(launchUri);
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 2)),
      ModalRoute.withName('/'),
    );
  }

  void _sendAlert() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const SendAlert()));
  }

  void _playAlarm() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                const PlayAlarm(mode: 'loggedIn')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("Emergency"),
            leading: BackButton(
              color: Colors.white,
              onPressed: _backScreen,
            )),
        body: Center(
          child: Column(children: [
            const Text('Emergency declared!'),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _setEmergency,
                child: _saved
                    ? Text('Update your emergency number',
                        style: Theme.of(context).textTheme.headline6)
                    : Text(
                        'Set your emergency number',
                        style: Theme.of(context).textTheme.headline6,
                      )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _saved ? _dialEmergency : null,
                child: Text(
                  'Dial your emergency number',
                  style: Theme.of(context).textTheme.headline6,
                )),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _sendAlert,
                child: Text('Send Alert',
                    style: Theme.of(context).textTheme.headline6)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _playAlarm,
                child: Text('Play Alarm',
                    style: Theme.of(context).textTheme.headline6)),
          ]),
        ));
  }
}

class SetEmergencyNumberLoginState extends State<SetEmergencyNumberLogin>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _controllerNumber = TextEditingController();
  late final PhoneNumber _initialNumber = PhoneNumber(isoCode: 'GB');

  final TextEditingController _controllerNumberHelpline =
      TextEditingController();

  late final TabController _controller = TabController(length: 2, vsync: this);

  bool _valid = false;
  bool _saved = false;

  String _number = '';

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTabSelection);
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _saved = await DatabaseHelper.isEmergencyNumberSavedFirebase(
        globals.user.username);
  }

  @override
  void dispose() {
    _controller.dispose();
    _controllerNumber.dispose();
    super.dispose();
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const Emergency()),
      ModalRoute.withName('/'),
    );
  }

  void _handleTabSelection() {
    if (_controller.indexIsChanging) {
      switch (_controller.index) {
        case 0:
          _controllerNumberHelpline.clear();
          break;
        case 1:
          _controllerNumber.clear();
          break;
      }
    }
  }

  String returnMessage(String text) {
    bool check;
    try {
      int.parse(text);
      check = true;
    } catch (e) {
      check = false;
    }

    if (text.length < 3 && text.isNotEmpty) {
      return 'Too short';
    } else if (text.length > 15) {
      return 'Too long';
    } else if (check == false && text.isNotEmpty) {
      return 'Invalid number';
    } else {
      return 'check';
    }
  }

  bool isValid(String text) {
    bool check;
    try {
      int.parse(text);
      check = true;
    } catch (e) {
      check = false;
    }
    return text.length >= 3 && text.length <= 15 && check;
  }

  void _submitNumber() async {
    if (isValid(_controllerNumberHelpline.text)) {
      await DatabaseHelper.setEmergencyNumberFirebase(
          globals.user.username, _controllerNumberHelpline.text, '', 'h');
    }

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const Emergency()),
      ModalRoute.withName('/'),
    );
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
                          icon: Icon(Icons.groups_rounded),
                          child: Text("Personal number"),
                          height: 55),
                      Tab(
                          icon: Icon(Icons.phone_in_talk_rounded),
                          child: Text("Emergency helpline"),
                          height: 55),
                    ])),
                body: TabBarView(
                    physics: const NeverScrollableScrollPhysics(),
                    controller: _controller,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 30),
                          const Text("Enter the phone number here",
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 30),
                          Form(
                            key: _formKey,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                InternationalPhoneNumberInput(
                                  initialValue: _initialNumber,
                                  onInputChanged: (PhoneNumber number) {
                                    setState(() {
                                      _valid = false;
                                    });
                                  },
                                  onSaved: (PhoneNumber number) async {
                                    await DatabaseHelper
                                        .setEmergencyNumberFirebase(
                                            globals.user.username,
                                            number.phoneNumber!,
                                            number.isoCode!,
                                            'p');
                                    setState(() {
                                      _saved = true;
                                    });
                                  },
                                  selectorConfig: const SelectorConfig(
                                    selectorType:
                                        PhoneInputSelectorType.BOTTOM_SHEET,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle:
                                      const TextStyle(color: Colors.black),
                                  textFieldController: _controllerNumber,
                                  formatInput: false,
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                          signed: true, decimal: true),
                                  inputBorder: const OutlineInputBorder(),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    if (_formKey.currentState?.validate() ==
                                        true) {
                                      setState(() {
                                        _valid = true;
                                      });
                                    }
                                  },
                                  child: _valid
                                      ? const Text('Validated')
                                      : const Text('Validate'),
                                  style: ButtonStyle(
                                    backgroundColor: _valid
                                        ? MaterialStateProperty.all<Color>(
                                            Colors.greenAccent)
                                        : MaterialStateProperty.all<Color>(
                                            Colors.blueAccent),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: _valid
                                      ? () {
                                          if (_formKey.currentState
                                                  ?.validate() ==
                                              true) {
                                            _formKey.currentState?.save();
                                            Navigator.pushAndRemoveUntil<void>(
                                              context,
                                              MaterialPageRoute<void>(
                                                  builder:
                                                      (BuildContext context) =>
                                                          const Emergency()),
                                              ModalRoute.withName('/'),
                                            );
                                          }
                                        }
                                      : null,
                                  child: _saved
                                      ? const Text('Saved')
                                      : const Text('Save'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          const Text("Enter the phone number here:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(
                            height: 30,
                          ),
                          TextFormField(
                            controller: _controllerNumberHelpline,
                            autovalidateMode: AutovalidateMode.always,
                            validator: (text) {
                              String text2 = returnMessage(text!);
                              if (text2 != 'check') {
                                return text2;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              if (mounted) {
                                setState(() {
                                  _number = _controllerNumberHelpline.text;
                                });
                              }
                            },
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          ElevatedButton(
                            // only enable the button if all inputs are valid
                            onPressed: isValid(_number) ? _submitNumber : null,
                            child: Text(
                              'Submit',
                              style: Theme.of(context).textTheme.headline6,
                            ),
                            //changes colour of button to further highlight valid/invalid input
                            style: ButtonStyle(
                              backgroundColor: isValid(_number)
                                  ? MaterialStateProperty.all<Color>(
                                      Colors.blueAccent)
                                  : MaterialStateProperty.all<Color>(
                                      Colors.grey),
                            ),
                          ),
                        ],
                      ),
                    ]))));
  }
}

class SendAlertState extends State<SendAlert> {
  late NotificationHandler n;
  final TextEditingController _controller = TextEditingController();
  String _message = '';

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    n = NotificationHandler();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const Emergency()),
      ModalRoute.withName('/'),
    );
  }

  void _confirmAlert() async {
    List<Map<String, dynamic>> f =
        await DatabaseHelper.getFriendsFirebase(globals.user.username);
    await DatabaseHelper.startStreamFirebase(globals.user.username);
    List<String> usernames = [];
    List<String> tokens = [];
    for (Map<String, dynamic> m in f) {
      usernames
          .add(m['user1'] == globals.user.username ? m['user2'] : m['user1']);
    }
    for (String u in usernames) {
      Map<String, dynamic> user =
          await DatabaseHelper.getUserByUsernameFirebase(u);
      tokens.add(user['tokenId']);
      await DatabaseHelper.sendMessage(
          globals.user.username, u, 'NEW ALERT:\n' + _message);
    }
    await n.sendNotification(
        tokens, globals.user.username + " is in distress!", "New alert");

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text("Alert sent successfully"),
    ));

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const Emergency()),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: const Text("Alert"),
            leading: BackButton(
              color: Colors.white,
              onPressed: _backScreen,
            )),
        body: Center(
          child: Column(children: [
            const Text('Add optional message to go with the alert:'),
            TextFormField(
              controller: _controller,
              onChanged: (value) {
                if (mounted) {
                  setState(() {
                    _message = _controller.text;
                  });
                }
              },
            ),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _confirmAlert,
                child: Text('Send Alert',
                    style: Theme.of(context).textTheme.headline6)),
          ]),
        ));
  }
}
