import '../main.dart';

import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyNoLogin extends StatefulWidget {
  const EmergencyNoLogin({Key? key}) : super(key: key);

  @override
  EmergencyNoLoginState createState() => EmergencyNoLoginState();
}

class SetEmergencyNumber extends StatefulWidget {
  const SetEmergencyNumber({Key? key}) : super(key: key);

  @override
  SetEmergencyNumberState createState() => SetEmergencyNumberState();
}

class EmergencyNoLoginState extends State<EmergencyNoLogin> {
  bool _saved = false;

  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
    String? s = _preferences?.getString("number");
    if (s != null) {
      setState(() {
        _saved = true;
      });
    }
  }

  void _setEmergency() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const SetEmergencyNumber()));
  }

  void _dialEmergency() async {
    String? s = _preferences?.getString("number");
    if (s != null) {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: s,
      );
      await launchUrl(launchUri);
    }
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              const EmergencyOrLogin(loggedOut: 'y')),
      ModalRoute.withName('/'),
    );
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
            const Text('Emergency declared - no login details found!'),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _setEmergency,
                child: _saved
                    ? Text('Update your emergency number',
                        style: Theme.of(context).textTheme.headline6)
                    : Text(
                        'Set your emergency number',
                        style: Theme.of(context).textTheme.headline6,
                      )),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _saved ? _dialEmergency : null,
                child: Text(
                  'Dial your emergency number',
                  style: Theme.of(context).textTheme.headline6,
                )),
          ]),
        ));
  }
}

class SetEmergencyNumberState extends State<SetEmergencyNumber>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _controllerNumber = TextEditingController();
  late PhoneNumber _initialNumber = PhoneNumber(isoCode: 'GB');

  final TextEditingController _controllerNumberHelpline =
      TextEditingController();
  String _initialNumberHelpline = 'e';

  late final TabController _controller = TabController(length: 2, vsync: this);

  bool _valid = false;
  bool _saved = false;

  String _number = '';

  SharedPreferences? _preferences;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTabSelection);
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _preferences = await SharedPreferences.getInstance();
    if (_preferences?.getString('numberMode') == 'h') {
      var exists = _preferences?.getString('number');
      if (exists != null) {
        _initialNumberHelpline = exists;
        _controllerNumberHelpline.text = exists;
      }
    } else {
      _initialNumber = PhoneNumber(
          phoneNumber: _preferences?.getString('number'),
          isoCode: _preferences?.getString('code'));
    }
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
          builder: (BuildContext context) => const EmergencyNoLogin()),
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
      int num = int.parse(text);
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
      int num = int.parse(text);
      check = true;
    } catch (e) {
      check = false;
    }
    return text.length >= 3 && text.length <= 15 && check;
  }

  void _submitNumber() async {
    if (isValid(_controllerNumberHelpline.text)) {
      _preferences?.setString('number', _controllerNumberHelpline.text);
      _preferences?.remove('code');
      _preferences?.setString('numberMode', 'h');
    }

    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const EmergencyNoLogin()),
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
                                  onSaved: (PhoneNumber number) {
                                    _preferences?.setString(
                                        "number", number.phoneNumber!);
                                    _preferences?.setString(
                                        "code", number.isoCode!);
                                    _preferences?.setString("numberMode", "p");
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
                                                  builder: (BuildContext
                                                          context) =>
                                                      const EmergencyNoLogin()),
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
