import '../helpers/user.dart';

import 'package:location/location.dart' as loc;

import 'dart:async';

StreamSubscription<loc.LocationData>? locationSubscription;
StreamSubscription<loc.LocationData>? locationSubscriptionSelf;
List<Map<String, dynamic>> viewers = [];
List<String> ids = [];

List<Map<String, dynamic>> unread = [];
List<Map<String, dynamic>> streams = [];
List<Map<String, dynamic>> requests = [];

User user = User('', '', '');
