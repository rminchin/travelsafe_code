import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:travelsafe_v1/helpers/database_helper.dart';

import '../chat/chat_functionality.dart';
import '../helpers/user.dart';
import '../screens/homepage.dart';

class DrawMap extends StatefulWidget {
  String username;
  User user;
  DrawMap({Key? key, required this.username, required this.user})
      : super(key: key);

  @override
  DrawMapState createState() => DrawMapState();
}

class DrawMapState extends State<DrawMap> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  bool _called = false;
  double _zoom = 16;

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    await DatabaseHelper.addViewerFirebase(widget.username, widget.user.username);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance.collection('location').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                mymap(snapshot);
              }
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    title: Text(widget.username + "'s location"),
                    leading: BackButton(
                      color: Colors.white,
                      onPressed: _backScreenStoppedWatching,
                    ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.question_answer_rounded),
                      onPressed: () async {
                        await DatabaseHelper.removeViewerFirebase(widget.username, widget.user.username);
                        Map<String,dynamic> userFound = await DatabaseHelper.getUserByUsernameFirebase(widget.username);
                        User user2 = User(userFound['username'], userFound['password'], userFound['nickname']);
                        Navigator.pushAndRemoveUntil<void>(
                          context,
                          MaterialPageRoute<void>(
                              builder: (BuildContext context) => OpenChat(user: widget.user, user2: user2)),
                          ModalRoute.withName('/'),
                        );
                      },
                    )
                  ]
                ),
                body: GoogleMap(
                  mapType: MapType.normal,
                  markers: {
                    Marker(
                        position: findLoc(snapshot),
                        markerId: const MarkerId('id'),
                        icon: BitmapDescriptor.defaultMarkerWithHue(
                            BitmapDescriptor.hueMagenta)),
                  },
                  initialCameraPosition:
                      CameraPosition(target: findLoc(snapshot), zoom: _zoom),
                  onMapCreated: (GoogleMapController controller) async {
                    setState(() {
                      _controller = controller;
                      _added = true;
                    });
                  },
                ));
          },
        ));
  }

  Future<void> mymap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    try {
      if (snapshot.data!.docs.isNotEmpty) {
        double zoom = await _controller.getZoomLevel();
        setState(() {
          _zoom = zoom;
        });

        await _controller
            .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
                target: LatLng(
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.username)['latitude'],
                  snapshot.data!.docs.singleWhere(
                      (element) => element.id == widget.username)['longitude'],
                ),
                zoom: _zoom)));
      }
    } on StateError {
      if (!_called) {
        _backScreenStopped();
      }
    }
  }

  LatLng findLoc(AsyncSnapshot snapshot) {
    LatLng loc = const LatLng(0, 0);
    try {
      loc = LatLng(
        snapshot.data!.docs.singleWhere(
            (element) => element.id == widget.username)['latitude'],
        snapshot.data!.docs.singleWhere(
            (element) => element.id == widget.username)['longitude'],
      );
      return loc;
    } on StateError {
      if (!_called) {
        _backScreenStopped();
      }
    }
    return loc;
  }

  Future<void> _backScreenStopped() async {
    _called = true;
    await DatabaseHelper.addStreamFirebase(widget.username, '');
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              HomePage(user: widget.user, tab: 0)),
      ModalRoute.withName('/'),
    );
  }

  Future<void> _backScreenStoppedWatching() async {
    await DatabaseHelper.removeViewerFirebase(widget.username, widget.user.username);
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) =>
              HomePage(user: widget.user, tab: 0)),
      ModalRoute.withName('/'),
    );
  }
}
