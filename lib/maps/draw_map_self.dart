import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../screens/homepage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

class DrawMapSelf extends StatefulWidget {
  const DrawMapSelf({Key? key}) : super(key: key);

  @override
  DrawMapSelfState createState() => DrawMapSelfState();
}

class DrawMapSelfState extends State<DrawMapSelf> {
  final loc.Location location = loc.Location();
  late GoogleMapController _controller;
  bool _added = false;
  double _zoom = 16;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 400,
        child: StreamBuilder(
          stream:
              FirebaseFirestore.instance.collection('locationSelf').snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (_added) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              } else {
                myMap(snapshot);
              }
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            return Scaffold(
                appBar: AppBar(
                    centerTitle: true,
                    title: const Text('Your location'),
                    leading: BackButton(
                      color: Colors.white,
                      onPressed: _backScreen,
                    )),
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
                    if (mounted) {
                      setState(() {
                        _controller = controller;
                        _added = true;
                      });
                    }
                  },
                ));
          },
        ));
  }

  Future<void> myMap(AsyncSnapshot<QuerySnapshot> snapshot) async {
    double zoom = await _controller.getZoomLevel();
    if (mounted) {
      setState(() {
        _zoom = zoom;
      });
    }

    await _controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
            target: LatLng(
              snapshot.data!.docs.singleWhere(
                  (element) => element.id == globals.user.username)['latitude'],
              snapshot.data!.docs.singleWhere((element) =>
                  element.id == globals.user.username)['longitude'],
            ),
            zoom: _zoom)));
  }

  LatLng findLoc(AsyncSnapshot snapshot) {
    LatLng loc = const LatLng(0, 0);
    loc = LatLng(
      snapshot.data!.docs.singleWhere(
          (element) => element.id == globals.user.username)['latitude'],
      snapshot.data!.docs.singleWhere(
          (element) => element.id == globals.user.username)['longitude'],
    );
    return loc;
  }

  Future<void> _backScreen() async {
    globals.locationSubscriptionSelf?.cancel();
    globals.locationSubscriptionSelf = null;
    await DatabaseHelper.removeLocationSelf(globals.user.username);
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 0)),
      ModalRoute.withName('/'),
    );
  }
}
