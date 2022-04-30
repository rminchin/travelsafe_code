import 'draw_map.dart';
import 'draw_map_self.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/notification_handler.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';

import 'dart:async';

class MapGenerate extends StatefulWidget {
  const MapGenerate({Key? key}) : super(key: key);

  @override
  MapGenerateState createState() => MapGenerateState();
}

class MapGenerateState extends State<MapGenerate> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  StreamSubscription<loc.LocationData>? _locationSubscriptionSelf;
  List<Map<String, dynamic>> _friends = [];
  bool _streaming = false;
  late NotificationHandler n;

  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _streams = [];
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _requestPermission();
    initializePreference().whenComplete(() {
      setState(() {
        _locationSubscriptionSelf?.cancel();
        _locationSubscriptionSelf = null;
        globals.locationSubscriptionSelf?.cancel();
        globals.locationSubscriptionSelf = null;
      });
      if (_streaming == false) {
        setState(() {
          _locationSubscription?.cancel();
          globals.locationSubscription?.cancel();
          _locationSubscription = null;
          globals.locationSubscription = null;
          globals.viewers = [];
        });
      } else {
        setState(() {
          _locationSubscription = globals.locationSubscription;
        });
      }
      location.changeSettings(
          interval: 3000, accuracy: loc.LocationAccuracy.high);
      location.enableBackgroundMode(enable: true);
      globals.context = context;
      n = NotificationHandler();
    });
  }

  Future<void> initializePreference() async {
    bool check2 =
        await DatabaseHelper.checkStreamingFirebase(globals.user.username);
    if (check2) {
      if (mounted) {
        setState(() {
          _streaming = true;
        });
      }
    }
    _friends = await DatabaseHelper.getFriendsFirebase(globals.user.username);
    globals.viewers =
        await DatabaseHelper.getViewersFirebase(globals.user.username);
    bool check = await DatabaseHelper.findStreamFirebase();
    if (check) {
      String u = await DatabaseHelper.getUsernameStreamFirebase();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(u + " has stopped their stream"),
        ));
      });
      await DatabaseHelper.removeStreamFirebase(u);
    }
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
    return Scaffold(
      body: Column(
        children: [
          Text('${globals.user.nickname}\'s map'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _streaming ? _stopListeningLocation : _listenLocation,
            child: _streaming
                ? Text('Stop sharing location',
                    style: Theme.of(context).textTheme.headline6)
                : Text('Start sharing location',
                    style: Theme.of(context).textTheme.headline6),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _showLocation,
            child: Text('Show my location',
                style: Theme.of(context).textTheme.headline6),
          ),
          Text(_streaming
              ? globals.viewers.isNotEmpty
                  ? "LIVE: " + globals.viewers.length.toString() + " watching"
                  : "LIVE: Waiting for people to join"
              : ""),
          Expanded(
              child: StreamBuilder(
            stream:
                FirebaseFirestore.instance.collection('location').snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              updateViewers();
              return buildTiles(snapshot);
            },
          )),
        ],
      ),
    );
  }

  void updateViewers() async {
    List<Map<String, dynamic>> viewers =
        await DatabaseHelper.getViewersFirebase(globals.user.username);
    if (viewers.length != globals.viewers.length) {
      if (viewers.length > globals.viewers.length) {
        for (Map<String, dynamic> m in viewers) {
          if (!globals.viewers.contains(m)) {
            ScaffoldMessenger.of(globals.context).showSnackBar(SnackBar(
              content: Text(m['viewer'] + " has joined your stream!"),
            ));
          }
        }
      } else {
        for (Map<String, dynamic> m in globals.viewers) {
          if (!viewers.contains(m)) {
            ScaffoldMessenger.of(globals.context).showSnackBar(SnackBar(
              content: Text(m['viewer'] + " has left your stream"),
            ));
          }
        }
      }
      globals.viewers = viewers;
    }
    if (mounted) {
      setState(() {
        globals.viewers = viewers;
      });
    }
  }

  Widget buildTiles(AsyncSnapshot snapshot) {
    List<dynamic> itemsList = [];
    List<String> names = [];
    for (Map<String, dynamic> n in _friends) {
      n['user1'] == globals.user.username
          ? names.add(n['user2'])
          : names.add(n['user1']);
    }
    for (dynamic f in snapshot.data?.docs) {
      if (names.contains(f.id)) {
        itemsList.add(f);
      }
    }
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(itemsList[index]['name'].toString()),
            subtitle: Row(
              children: [
                Text(itemsList[index]['latitude'].toString()),
                const SizedBox(
                  width: 20,
                ),
                Text(itemsList[index]['longitude'].toString()),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DrawMap(username: itemsList[index].id)));
              },
            ),
          );
        });
  }

  _getLocation() async {
    final loc.LocationData _locationResult = await location.getLocation();
    await DatabaseHelper.addLocation(
        _locationResult, globals.user.username, globals.user.nickname);
  }

  _getLocationSelf() async {
    final loc.LocationData _locationResult = await location.getLocation();
    await DatabaseHelper.addLocationSelf(
        _locationResult, globals.user.username, globals.user.nickname);
  }

  _showLocation() async {
    await _getLocationSelf();
    _locationSubscriptionSelf =
        location.onLocationChanged.handleError((onError) {
      _locationSubscriptionSelf?.cancel();
      if (mounted) {
        setState(() {
          _locationSubscriptionSelf = null;
        });
      }
    }).listen((loc.LocationData locationCurrent) async {
      await DatabaseHelper.addLocationSelf(
          locationCurrent, globals.user.username, globals.user.nickname);
    });
    if (mounted) {
      setState(() {
        globals.locationSubscriptionSelf = _locationSubscriptionSelf;
      });
    }
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const DrawMapSelf()));
  }

  Future<void> _listenLocation() async {
    await _getLocation();
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
    }
    await n.sendNotification(tokens,
        globals.user.username + " has begun streaming!", "New location stream");
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      _locationSubscription?.cancel();
      if (mounted) {
        setState(() {
          _locationSubscription = null;
        });
      }
    }).listen((loc.LocationData locationCurrent) async {
      if (!_streaming) {
        if (mounted) {
          setState(() {
            _streaming = true;
          });
        }
      }
      await DatabaseHelper.addLocation(
          locationCurrent, globals.user.username, globals.user.nickname);
    });
    List<Map<String, dynamic>> viewers =
        await DatabaseHelper.getViewersFirebase(globals.user.username);
    if (mounted) {
      setState(() {
        globals.locationSubscription = _locationSubscription;
        globals.viewers = viewers;
      });
    }
  }

  _stopListeningLocation() async {
    _locationSubscription?.cancel();
    globals.locationSubscription?.cancel();
    await DatabaseHelper.removeLocation(globals.user.username);
    if (mounted) {
      setState(() {
        _locationSubscription = null;
        _streaming = false;
        globals.locationSubscription = null;
        globals.viewers = [];
      });
    }
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}
