import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import '../helpers/database_helper.dart';
import '../helpers/user.dart';
import '../screens/homepage.dart';

//TODO
//check zoom changing works
//stop streaming builder and location stream on back button?

class DrawMap extends StatefulWidget {
  String username;
  StreamSubscription<loc.LocationData>? locationSubscription;
  DrawMap(
      {Key? key, required this.username, required this.locationSubscription})
      : super(key: key);

  @override
  DrawMapState createState() => DrawMapState();
}

class DrawMapStream extends StatefulWidget {
  String username;
  StreamSubscription<loc.LocationData>? locationSubscription;
  String userWatching;
  DrawMapStream(
      {Key? key,
      required this.username,
      required this.locationSubscription,
      required this.userWatching})
      : super(key: key);

  @override
  DrawMapStreamState createState() => DrawMapStreamState();
}

class DrawMapState extends State<DrawMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  double _zoom = 16;

  void _backScreen() async {
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(widget.username);
    widget.locationSubscription?.cancel();
    setState(() {
      widget.locationSubscription = null;
    });
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => HomePage(
              user: User(u['username'], u['password'], u['nickname']), tab: 0)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('location').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              updateMap(snapshot);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: const Text("Your Location"),
                  leading: BackButton(
                    color: Colors.white,
                    onPressed: _backScreen,
                  )),
              body: GoogleMap(
                mapType: MapType.normal,
                markers: {
                  Marker(
                      position: LatLng(
                          snapshot.data!.docs.singleWhere((element) =>
                              element.id == widget.username)['latitude'],
                          snapshot.data!.docs.singleWhere((element) =>
                              element.id == widget.username)['longitude']),
                      markerId: const MarkerId('id'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed))
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.username)['latitude'],
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.username)['longitude']),
                    zoom: _zoom),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
                  });
                },
              ),
            );
          }),
    );
  }

  Future<void> updateMap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    double zoom = await _controller.getZoomLevel();
    setState(() {
      _zoom = zoom;
    });
    await _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.username)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.username)['longitude']),
            zoom: _zoom)));
  }
}

class DrawMapStreamState extends State<DrawMapStream> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  double _zoom = 16;

  void _backScreen() async {
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(widget.username);
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => HomePage(
              user: User(u['username'], u['password'], u['nickname']), tab: 0)),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('locationStream')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              updateMap(snapshot);
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
              appBar: AppBar(
                  centerTitle: true,
                  title: Text("TravelSafe - watching ${widget.userWatching}"),
                  leading: BackButton(
                    color: Colors.white,
                    onPressed: _backScreen,
                  )),
              body: GoogleMap(
                mapType: MapType.normal,
                markers: {
                  Marker(
                      position: LatLng(
                          snapshot.data!.docs.singleWhere((element) =>
                              element.id == widget.username)['latitude'],
                          snapshot.data!.docs.singleWhere((element) =>
                              element.id == widget.username)['longitude']),
                      markerId: const MarkerId('id'),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueRed))
                },
                initialCameraPosition: CameraPosition(
                    target: LatLng(
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.username)['latitude'],
                        snapshot.data!.docs.singleWhere((element) =>
                            element.id == widget.username)['longitude']),
                    zoom: _zoom),
                onMapCreated: (GoogleMapController controller) async {
                  setState(() {
                    _controller = controller;
                    _added = true;
                  });
                },
              ),
            );
          }),
    );
  }

  Future<void> updateMap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    double zoom = await _controller.getZoomLevel();
    setState(() {
      _zoom = zoom;
    });
    await _controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.username)['latitude'],
                snapshot.data!.docs.singleWhere(
                    (element) => element.id == widget.username)['longitude']),
            zoom: _zoom)));
  }
}
