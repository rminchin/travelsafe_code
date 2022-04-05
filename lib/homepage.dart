import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

import 'emergency.dart';
import 'settings.dart';

class HomePage extends StatefulWidget {
  final User user;
  final int tab;
  const HomePage({Key? key, required this.user, required this.tab}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late int _currentIndex = widget.tab;

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
        widget2 = const FlutterLogo(
          size: 200,
        );
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
              automaticallyImplyLeading: false, centerTitle: true
              ,title: const Text("TravelSafe")),
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
              items: const [
                BottomNavigationBarItem(
                    label: "Map", icon: Icon(Icons.location_on_sharp)),
                BottomNavigationBarItem(
                    label: "Network", icon: Icon(Icons.people_outline_rounded)),
                BottomNavigationBarItem(
                    label: "Home", icon: Icon(Icons.home_rounded)),
                BottomNavigationBarItem(
                    label: "Chat", icon: Icon(Icons.question_answer_rounded)),
                BottomNavigationBarItem(
                    label: "Settings", icon: Icon(Icons.settings)),
              ]),
        ),
      ),
    );
  }
}
