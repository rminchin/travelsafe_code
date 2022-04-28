import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'package:travelsafe_v1/emergency/emergency.dart';
import 'package:travelsafe_v1/settings/settings.dart' as my_settings;
import 'package:travelsafe_v1/network/network_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import '../chat/chat_general_screen.dart';
import '../network/network_functionality.dart';
import '../maps/map.dart';
import '../helpers/globals.dart' as globals;

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
  late BottomNavigationBarItem _map = const BottomNavigationBarItem(icon: Icon(Icons.location_on_sharp), label: 'Map');
  late BottomNavigationBarItem _chat = const BottomNavigationBarItem(icon: Icon(Icons.question_answer_rounded), label: 'Chat');

  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _streams = [];
  List<Map<String, dynamic>> _chats = [];

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
        } else if (title == 'New message'){
          Navigator.pushAndRemoveUntil<void>(
            context,
            MaterialPageRoute<void>(
                builder: (BuildContext context) => HomePage(user: widget.user, tab: 3)),
            ModalRoute.withName('/'),
          );
        }
      }
    });
  }

  Future<void> initializePreference() async {
    await DatabaseHelper.getConversationsFirebase(widget.user.username);
    updateScreen();
  }

  void _submitEmergency() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => Emergency(user: widget.user)));
  }

  void updateScreen() async {
    _requests = await DatabaseHelper.getRequestsReceivedFirebase(widget.user.username);
    _streams = await DatabaseHelper.getLiveStreamsFirebase(widget.user.username);
    _chats = await DatabaseHelper.getAllUnreadFirebase(widget.user.username);
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
    } else{
      setState(() {
        _network = const BottomNavigationBarItem(
            icon: Icon(Icons.people_rounded), label: 'Network');
      });
    }

    if (_streams.isNotEmpty) {
      setState(() {
        _map = BottomNavigationBarItem(
          label: 'Map',
          icon: Stack(children: const <Widget>[
            Icon(Icons.location_on_sharp),
            Positioned(
              top: 0.0,
              right: 0.0,
              child:
              Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
            )
          ]),
        );
      });
    } else{
      setState(() {
        _map = const BottomNavigationBarItem(
            icon: Icon(Icons.location_on_sharp), label: 'Map');
      });
    }

    if(_chats.isNotEmpty) {
      setState(() {
        _chat = BottomNavigationBarItem(
          label: 'Chat',
          icon: Stack(children: const <Widget>[
            Icon(Icons.question_answer_rounded),
            Positioned(
              top: 0.0,
              right: 0.0,
              child:
              Icon(Icons.brightness_1, size: 8.0, color: Colors.redAccent),
            )
          ]),
        );
      });
    } else{
      setState(() {
        _chat = const BottomNavigationBarItem(
            icon: Icon(Icons.question_answer_rounded), label: 'Chat');
      });
    }

    if(_requests.length > globals.requests.length){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New friend request!"),
      ));
    }

    if(_streams.length > globals.streams.length){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New livestream started!"),
      ));
    }

    if(_chats.length > globals.unread.length){
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("New message received!"),
      ));
    }

    setState(() {
      globals.requests = _requests;
      globals.streams = _streams;
      globals.unread = _chats;
    });
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
        widget2 = my_settings.Settings(user: widget.user);
        break;
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: StreamBuilder(
        stream:
        FirebaseFirestore.instance.collection('allNotifications').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          updateScreen();
          return DefaultTabController(
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
                  onTap: (newIndex) =>
                      setState(() {
                        _currentIndex = newIndex;
                      }),
                  items: [
                    _map,
                    _network,
                    const BottomNavigationBarItem(
                        label: "Home", icon: Icon(Icons.home_rounded)),
                    _chat,
                    const BottomNavigationBarItem(
                        label: "Settings", icon: Icon(Icons.settings)),
                  ]),
            ),
          );
        })
    );
  }
}
