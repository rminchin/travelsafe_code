import 'network_functionality.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Network extends StatefulWidget {
  const Network({Key? key}) : super(key: key);

  @override
  NetworkState createState() => NetworkState();
}

class NetworkState extends State<Network> {
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _streams = [];
  List<Map<String, dynamic>> _chats = [];

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
        });
  }
}
