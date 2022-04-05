import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

class AddFriend extends StatefulWidget {
  User user;
  AddFriend({Key? key, required this.user}) : super(key: key);

  @override
  AddFriendState createState() => AddFriendState();
}

class ViewRequests extends StatefulWidget {
  User user;
  ViewRequests({Key? key, required this.user}) : super(key: key);

  @override
  ViewRequestsState createState() => ViewRequestsState();
}

class ManageNetwork extends StatefulWidget {
  User user;
  ManageNetwork({Key? key, required this.user}) : super(key: key);

  @override
  ManageNetworkState createState() => ManageNetworkState();
}

class AddFriendState extends State<AddFriend> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")));
  }
}

class ViewRequestsState extends State<ViewRequests> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")));
  }
}

class ManageNetworkState extends State<ManageNetwork> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(centerTitle: true, title: const Text("TravelSafe")));
  }
}
