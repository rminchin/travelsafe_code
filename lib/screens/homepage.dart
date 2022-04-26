import 'dart:async';

import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'package:travelsafe_v1/emergency/emergency.dart';
import 'package:travelsafe_v1/settings/settings.dart';
import 'package:travelsafe_v1/network/network_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../chat/chat_general_screen.dart';
import '../network/network_functionality.dart';
import '../maps/map.dart';

class HomePage extends StatefulWidget {
  final User user;
  final int tab;
  const HomePage({Key? key, required this.user, required this.tab})
      : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late int _currentIndex = widget.tab;
  late BottomNavigationBarItem _network = const BottomNavigationBarItem(
      icon: Icon(Icons.people_rounded), label: 'Network');
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
    configOneSignal();
  }

  void configOneSignal() {
    OneSignal.shared.setAppId('4482ca21-5afa-43f7-8f09-d7b0b7d196f1');
    OneSignal.shared.setLogLevel(OSLogLevel.none, OSLogLevel.none);

    OneSignal.shared.setNotificationWillShowInForegroundHandler((
        OSNotificationReceivedEvent event) {
      event.complete(null);
    });

    OneSignal.shared.setNotificationOpenedHandler((
        OSNotificationOpenedResult openedResult) {
      var title = openedResult.notification.title;
      if (title != null) {
        if (title == 'New contact request') {
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => ViewRequests(user: widget.user)),
            ModalRoute.withName('/'),
          );
        } else if (title == 'New contact added'){
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => ManageNetwork(user: widget.user)),
            ModalRoute.withName('/'),
          );
        } else if (title == 'New location stream'){
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => HomePage(user: widget.user, tab: 0)),
            ModalRoute.withName('/'),
          );
        }
      }
    });
  }

  Future<void> initializePreference() async {
    _requests = await DatabaseHelper.getRequestsReceivedFirebase(widget.user.username);
    if (_requests.isNotEmpty) {
      setState(() {
        _network = BottomNavigationBarItem(
          label: 'Network',
          icon: Stack(children: const <Widget>[
            Icon(Icons.people_rounded),
            Positioned(
              top: 0.0,
              right: 0.0,
              child:
                  Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
            )
          ]),
        );
      });
    }
  }

  void _submitEmergency() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => Emergency(user: widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    Widget widget2 = Container(); // default
    switch (_currentIndex) {
      case 0:
        widget2 = MapGenerate(user: widget.user);
        break;

      case 1:
        widget2 = Network(user: widget.user);
        break;

      case 2:
        widget2 = Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Logged in as ${widget.user.nickname}'),
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
              ]),
        );
        break;

      case 3:
        widget2 = ChatScreen(user: widget.user);
        break;

      case 4:
        widget2 = Settings(user: widget.user);
        break;
    }
    return WillPopScope(
      onWillPop: () async => false,
      child: DefaultTabController(
        length: 5,
        child: Scaffold(
          extendBody: true,
          appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              title: const Text("TravelSafe")),
          body: widget2,
          bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.blue[700],
              selectedFontSize: 15,
              unselectedFontSize: 13,
              iconSize: 30,
              currentIndex: _currentIndex,
              onTap: (newIndex) => setState(() {
                    _currentIndex = newIndex;
                  }),
              items: [
                const BottomNavigationBarItem(
                    label: 'Map', icon: Icon(Icons.location_on_sharp)),
                _network,
                const BottomNavigationBarItem(
                    label: "Home", icon: Icon(Icons.home_rounded)),
                const BottomNavigationBarItem(
                    label: 'Chat', icon: Icon(Icons.question_answer_rounded)),
                const BottomNavigationBarItem(
                    label: "Settings", icon: Icon(Icons.settings)),
              ]),
        ),
      ),
    );
  }
}
