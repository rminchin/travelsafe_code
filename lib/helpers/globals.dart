import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:location/location.dart' as loc;

StreamSubscription<loc.LocationData>? locationSubscription;
StreamSubscription<loc.LocationData>? locationSubscriptionSelf;
List<Map<String,dynamic>> viewers = [];
BuildContext context = context;