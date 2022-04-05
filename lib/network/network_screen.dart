import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import 'network_functionality.dart';

class Network extends StatefulWidget {
  final User user;
  const Network(
      {Key? key, required this.user})
      : super(key: key);

  @override
  NetworkState createState() => NetworkState();
}

class NetworkState extends State<Network> {
  @override
  void initState() {
    super.initState();
  }

  _addFriend() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => AddFriend(user: widget.user)));
  }

  _viewRequests() async {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ViewRequests(user: widget.user)));
  }

  void _manageNetwork() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => ManageNetwork(user: widget.user)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
              children: [
                Text('${widget.user.nickname} \'s network'),
                const SizedBox(height: 30),
                ElevatedButton(
                    onPressed: _addFriend,
                    child: Text(
                      'Add a friend',
                      style: Theme.of(context).textTheme.headline6,
                    )
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _viewRequests,
                  child: Text(
                    'View friend requests',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _manageNetwork,
                  child: Text(
                    'Manage network',
                    style: Theme.of(context).textTheme.headline6,
                  )
                )
              ]
          ),
        )
    );
  }
}
