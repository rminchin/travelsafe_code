import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart' as loc;
import 'package:permission_handler/permission_handler.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import '../helpers/user.dart';
import 'draw_map.dart';
import '../helpers/globals.dart' as globals;
import 'draw_map_self.dart';
import '../helpers/notification_handler.dart';

class MapGenerate extends StatefulWidget {
  User user;
  MapGenerate({Key? key, required this.user}) : super(key: key);

  @override
  MapGenerateState createState() => MapGenerateState();
}

class MapGenerateState extends State<MapGenerate> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  StreamSubscription<loc.LocationData>? _locationSubscriptionSelf;
  List<Map<String,dynamic>> _friends = [];
  bool _streaming = false;
  late NotificationHandler n;

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
      if(_streaming == false){
        setState(() {
          _locationSubscription?.cancel();
          globals.locationSubscription?.cancel();
          _locationSubscription = null;
          globals.locationSubscription = null;
          globals.viewers = [];
        });
      } else{
        setState(() {
          _locationSubscription = globals.locationSubscription;
        });
      }
      location.changeSettings(interval: 3000, accuracy: loc.LocationAccuracy.high);
      location.enableBackgroundMode(enable: true);
      globals.context = context;
      n = NotificationHandler();
    });
  }

  Future<void> initializePreference() async{
    bool check2 = await DatabaseHelper.checkStreamingFirebase(widget.user.username);
    if(check2){
      setState(() {
        _streaming = true;
      });
    }
    _friends = await DatabaseHelper.getFriendsFirebase(widget.user.username);
    globals.viewers = await DatabaseHelper.getViewersFirebase(widget.user.username);
    bool check = await DatabaseHelper.findStreamFirebase();
    if(check){
      String u = await DatabaseHelper.getUsernameStreamFirebase();
      WidgetsBinding.instance?.addPostFrameCallback((_){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(u + " has stopped their stream"),
        ));
      });
      await DatabaseHelper.removeStreamFirebase(u);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('${widget.user.nickname}\'s map'),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _streaming ? _stopListeningLocation : _listenLocation,
            child: _streaming ? Text('Stop sharing location',
                style: Theme.of(context).textTheme.headline6)
                : Text('Start sharing location', style: Theme.of(context).textTheme.headline6),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: _showLocation,
            child: Text('Show my location', style: Theme.of(context).textTheme.headline6),
          ),
          Text(_streaming ? globals.viewers.isNotEmpty ? "LIVE: " + globals.viewers.length.toString() + " watching" : "LIVE: Waiting for people to join" : ""),
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
    List<Map<String,dynamic>> viewers = await DatabaseHelper.getViewersFirebase(widget.user.username);
    if(viewers.length != globals.viewers.length){
      List<Map<String,dynamic>> viewers = await DatabaseHelper.getViewersFirebase(widget.user.username);
      if(viewers.length != globals.viewers.length) {
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
      setState(() {
        globals.viewers = viewers;
      });
    }
  }

  Widget buildTiles(AsyncSnapshot snapshot){
    List<dynamic> itemsList = [];
    List<String> names = [];
    for(Map<String,dynamic> n in _friends){
      n['user1'] == widget.user.username ? names.add(n['user2']) : names.add(n['user1']);
    }
    for(dynamic f in snapshot.data?.docs){
      if(names.contains(f.id)){
        itemsList.add(f);
      }
    }
    return ListView.builder(
        itemCount: itemsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title:
            Text(itemsList[index]['name'].toString()),
            subtitle: Row(
              children: [
                Text(itemsList[index]['latitude']
                    .toString()),
                const SizedBox(
                  width: 20,
                ),
                Text(itemsList[index]['longitude']
                    .toString()),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.directions),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) =>
                        DrawMap(username: itemsList[index].id, user: widget.user)));
              },
            ),
          );
        });
  }

  _getLocation() async {
    final loc.LocationData _locationResult = await location.getLocation();
    await DatabaseHelper.addLocation(_locationResult, widget.user.username, widget.user.nickname);
  }

  _getLocationSelf() async {
    final loc.LocationData _locationResult = await location.getLocation();
    await DatabaseHelper.addLocationSelf(_locationResult, widget.user.username, widget.user.nickname);
  }

  _showLocation() async {
    await _getLocationSelf();
    _locationSubscriptionSelf = location.onLocationChanged.handleError((onError) {
      _locationSubscriptionSelf?.cancel();
      setState(() {
        _locationSubscriptionSelf = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      await DatabaseHelper.addLocationSelf(currentlocation, widget.user.username, widget.user.nickname);
    });
    setState(() {
      globals.locationSubscriptionSelf = _locationSubscriptionSelf;
    });
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) =>
            DrawMapSelf(user: widget.user)));
  }

  Future<void> _listenLocation() async {
    await _getLocation();
    List<Map<String, dynamic>> f = await DatabaseHelper.getFriendsFirebase(widget.user.username);
    List<String> usernames = [];
    List<String> tokens = [];
    for(Map<String,dynamic> m in f){
      usernames.add(m['user1'] == widget.user.username ? m['user2'] : m['user1']);
    }
    for(String u in usernames){
      Map<String,dynamic> user = await DatabaseHelper.getUserByUsernameFirebase(u);
      tokens.add(user['tokenId']);
    }
    await n.sendNotification(tokens, widget.user.username + " has begun streaming!", "New location stream");
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData currentlocation) async {
      if(!_streaming){
        setState(() {
          _streaming = true;
        });
      }
      await DatabaseHelper.addLocation(currentlocation, widget.user.username, widget.user.nickname);
    });
    List<Map<String,dynamic>> viewers = await DatabaseHelper.getViewersFirebase(widget.user.username);
    setState(() {
      globals.locationSubscription = _locationSubscription;
      globals.viewers = viewers;
    });
  }

  _stopListeningLocation() async {
    _locationSubscription?.cancel();
    globals.locationSubscription?.cancel();
    await DatabaseHelper.removeLocation(widget.user.username);
    setState(() {
      _locationSubscription = null;
      _streaming = false;
      globals.locationSubscription = null;
      globals.viewers = [];
    });
  }

  _requestPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      print('done');
    } else if (status.isDenied) {
      _requestPermission();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    }
  }
}