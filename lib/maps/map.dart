import '../helpers/user.dart';
import 'draw_map.dart';

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:travelsafe_v1/helpers/database_helper.dart';
import 'package:location/location.dart' as loc;

class MapGenerate extends StatefulWidget {
  User user;
  MapGenerate({Key? key, required this.user}) : super(key: key);

  @override
  MapGenerateState createState() => MapGenerateState();
}

class MapGenerateState extends State<MapGenerate> {
  final loc.Location location = loc.Location();
  StreamSubscription<loc.LocationData>? _locationSubscription;
  bool _streaming = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    location.changeSettings(interval: 5000, accuracy: loc.LocationAccuracy.high);
    location.enableBackgroundMode(enable: true);
    if(_streaming == false){
      setState(() {
        _locationSubscription = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
          child: Column(children: [
            Text('${widget.user.nickname}\'s map'),
            const SizedBox(height: 30),
            ElevatedButton(
                onPressed: _streaming ? _stopListeningLocation : _listenLocation,
                child: _streaming ? Text('Stop sharing location',
                  style: Theme.of(context).textTheme.headline6)
                    : Text('Start sharing location', style: Theme.of(context).textTheme.headline6),
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _showLocation,
                child: Text('Show my location', style: Theme.of(context).textTheme.headline6)),
          ]),
        );
  }

  Future<void> _listenLocation() async {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData cLocation) async {
      _streaming = true;
      await DatabaseHelper.addLocation(cLocation, widget.user.username, widget.user.username);
    });
  }

  _stopListeningLocation() {
    _locationSubscription?.cancel();
    setState(() {
      _locationSubscription = null;
      _streaming = false;
    });
  }

  _showLocation() {
    _locationSubscription = location.onLocationChanged.handleError((onError) {
      print(onError);
      _locationSubscription?.cancel();
      setState(() {
        _locationSubscription = null;
      });
    }).listen((loc.LocationData cLocation) async {
      _streaming = true;
      await DatabaseHelper.addLocationSelf(cLocation, widget.user.username, widget.user.username);
    });

    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => DrawMap(username: widget.user.username, locationSubscription: _locationSubscription)));
  }

  _requestPermissions() async{
    var status = await Permission.location.request();
    if(status.isGranted){
      print('done');
    } else if(status.isDenied){
      _requestPermissions();
    } else if(status.isPermanentlyDenied){
      openAppSettings();
    }
  }
}
