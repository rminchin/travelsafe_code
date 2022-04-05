import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'package:travelsafe_v1/helpers/user.dart';

import 'emergency.dart';
import 'settings.dart';
import 'network_screen.dart';

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
  }

  Future<void> initializePreference() async {
    _requests = await DatabaseHelper.getRequestsFirebase(widget.user.username);
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
        widget2 = const FlutterLogo(
          size: 100,
        );
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
        widget2 = const FlutterLogo(
          size: 300,
        );
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
