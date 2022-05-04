import 'network_functionality.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;

import 'package:badges/badges.dart';
import 'package:flutter/material.dart';

class Network extends StatefulWidget {
  const Network({Key? key}) : super(key: key);

  @override
  NetworkState createState() => NetworkState();
}

class NetworkState extends State<Network> {
  List<Map<String, dynamic>> _requests = [];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _requests =
        await DatabaseHelper.getRequestsReceivedFirebase(globals.user.username);
  }

  _addFriend() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const AddFriend()));
  }

  _viewRequests() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const ViewRequests()));
  }

  void _manageNetwork() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => const ManageNetwork()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(children: [
        Text('${globals.user.nickname}\'s network'),
        const SizedBox(height: 30),
        ElevatedButton(
            onPressed: _addFriend,
            child: Text(
              'Add a friend',
              style: Theme.of(context).textTheme.headline6,
            )),
        const SizedBox(height: 30),
        Badge(
          badgeContent: Text(_requests.length.toString()),
          showBadge: _requests.isNotEmpty,
          child: ElevatedButton(
            onPressed: _viewRequests,
            child: Text(
              'View friend requests',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton(
            onPressed: _manageNetwork,
            child: Text(
              'Manage network',
              style: Theme.of(context).textTheme.headline6,
            ))
      ]),
    ));
  }
}
