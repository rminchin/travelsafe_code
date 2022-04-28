import '../helpers/database_helper.dart';
import '../helpers/notification_handler.dart';
import '../helpers/user.dart';
import '../screens/homepage.dart';

import 'package:flutter/material.dart';

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
  final TextEditingController _controllerSearchbar = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  late NotificationHandler n;

  List<Map<String, dynamic>> _friends = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    n = NotificationHandler();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _requests = await DatabaseHelper.getRequestsFirebase(widget.user.username);
    _friends = await DatabaseHelper.getFriendsFirebase(widget.user.username);
  }

  @override
  void dispose() {
    _controllerSearchbar.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  void _backScreen() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                HomePage(user: widget.user, tab: 1)));
  }

  Future<void> addFriend(String username) async {
    await DatabaseHelper.sendRequestFirebase(
        widget.user.username, username, widget.user.nickname);
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(username);
    if (mounted) {
      setState(() {
        _requests.add(u);
      });
    }
    await findMatchingUsers();
    await n.sendNotification([u['tokenId']],
        widget.user.username + " has added you!", "New contact request");
  }

  Future<void> removeRequest(String username) async {
    await DatabaseHelper.removeRequestFirebase(widget.user.username, username);
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(username);
    if (mounted) {
      setState(() {
        _requests.remove(u);
      });
    }
    await findMatchingUsers();
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> r = await DatabaseHelper.findUserFirebase(
        _controllerSearchbar.text, widget.user.username);
    List<Map<String, dynamic>> requests =
        await DatabaseHelper.getRequestsFirebase(widget.user.username);
    List<Map<String, dynamic>> friends =
        await DatabaseHelper.getFriendsFirebase(widget.user.username);
    if (mounted) {
      setState(() {
        _results = r;
        _requests = requests;
        _friends = friends;
      });
    }
  }

  Widget _buildItem(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    String user = _results[indexToUse]['username'];
    String nick = _results[indexToUse]['nickname'];
    bool friends = false;
    bool requested = false;
    for (Map<String, dynamic> m in _friends) {
      if (m['user1'] == user || m['user2'] == user) {
        friends = true;
      }
    }
    for (Map<String, dynamic> m in _requests) {
      if (m['from'] == user || m['to'] == user) {
        requested = true;
      }
    }
    return ListTile(
      title: Text(nick),
      subtitle: Text(user),
      trailing: ElevatedButton.icon(
          icon: Icon(
            friends
                ? Icons.people_rounded
                : requested
                    ? Icons.check
                    : Icons.arrow_right_alt_rounded,
            color: friends
                ? Colors.blueAccent
                : requested
                    ? Colors.green
                    : Colors.black,
          ),
          label: Text(friends
              ? 'Friends'
              : requested
                  ? 'Pending'
                  : 'Add'),
          onPressed: () async {
            if (!friends && !requested) {
              await addFriend(_results[index]['username']);
            } else if (requested) {
              await removeRequest(_results[index]['username']);
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
            foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("TravelSafe"),
          leading: BackButton(
            color: Colors.white,
            onPressed: _backScreen,
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: _controllerSearchbar,
                      autofocus: true,
                      focusNode: _searchFocus,
                      decoration: const InputDecoration(
                        labelText: 'Enter their username:',
                        prefixIcon: Icon(Icons.search),
                      ),
                      autovalidateMode: AutovalidateMode.always,
                      onChanged: (value) async {
                        await findMatchingUsers();
                      },
                    ),
                    Flexible(
                      child: _results.isNotEmpty &&
                              _controllerSearchbar.text.isNotEmpty
                          ? ListView.builder(
                              itemCount: _results.length * 2,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) =>
                                  _buildItem(index))
                          : const Text("No matching users found"),
                    )
                  ]),
            ),
          ],
        ));
  }
}

class ViewRequestsState extends State<ViewRequests> {
  List<Map<String, dynamic>> _results = [];
  late NotificationHandler n;

  @override
  void initState() {
    super.initState();
    n = NotificationHandler();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _results =
        await DatabaseHelper.getRequestsReceivedFirebase(widget.user.username);
  }

  void _backScreen() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                HomePage(user: widget.user, tab: 1)));
  }

  Future<void> acceptRequest(String username, String nick) async {
    await DatabaseHelper.acceptFriendFirebase(
        username, widget.user.username, nick, widget.user.nickname);
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(username);
    if (mounted) {
      setState(() {
        _results.remove(u);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Request accepted'),
    ));
    await findMatchingUsers();
    await n.sendNotification(
        [u['tokenId']],
        widget.user.username + " has accepted your request",
        "New contact added");
  }

  Future<void> removeRequest(String username) async {
    await DatabaseHelper.removeRequestFirebase(username, widget.user.username);
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(username);
    if (mounted) {
      setState(() {
        _results.remove(u);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Request rejected'),
    ));
    await findMatchingUsers();
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> r =
        await DatabaseHelper.getRequestsReceivedFirebase(widget.user.username);
    if (mounted) {
      setState(() {
        _results = r;
      });
    }
  }

  Widget _buildItem(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    String user = _results[indexToUse]['from'];
    String nick = _results[indexToUse]['from_nickname'];
    return ListTile(
      title: Text(nick),
      subtitle: Text(user),
      trailing: SizedBox(
        width: 200,
        child: Row(
          children: [
            GestureDetector(
                onTap: () async {
                  await acceptRequest(_results[index]['from'],
                      _results[index]['from_nickname']);
                },
                child: const Icon(Icons.check_rounded, color: Colors.green)),
            const SizedBox(width: 15),
            GestureDetector(
                onTap: () async {
                  await removeRequest(_results[index]['from']);
                },
                child: const Icon(Icons.close_rounded, color: Colors.red)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("TravelSafe"),
          leading: BackButton(
            color: Colors.white,
            onPressed: _backScreen,
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _results.isNotEmpty
                          ? ListView.builder(
                              itemCount: _results.length * 2,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) =>
                                  _buildItem(index))
                          : const Text("No pending requests"),
                    )
                  ]),
            ),
          ],
        ));
  }
}

class ManageNetworkState extends State<ManageNetwork> {
  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _friends = await DatabaseHelper.getFriendsFirebase(widget.user.username);
  }

  void _backScreen() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                HomePage(user: widget.user, tab: 1)));
  }

  Future<void> removeFriend(String username, String other) async {
    await DatabaseHelper.removeFriendFirebase(username, other);
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(other);
    if (mounted) {
      setState(() {
        _friends.remove(u);
      });
    }
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Friend removed'),
    ));
    await findMatchingUsers();
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> r =
        await DatabaseHelper.getFriendsFirebase(widget.user.username);
    if (mounted) {
      setState(() {
        _friends = r;
      });
    }
  }

  Widget _buildItem(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    String user = _friends[indexToUse]['user1'] == widget.user.username
        ? _friends[indexToUse]['user2']
        : _friends[indexToUse]['user1'];
    String nick = _friends[indexToUse]['user1_nickname'] == widget.user.nickname
        ? _friends[indexToUse]['user2_nickname']
        : _friends[indexToUse]['user1_nickname'];
    String since = _friends[indexToUse]['since'];
    return ListTile(
      leading: Text("Since\n" + since),
      title: Text(nick),
      subtitle: Text(user),
      trailing: GestureDetector(
          onTap: () async {
            await removeFriend(widget.user.username, user);
          },
          child: const Icon(Icons.remove_circle, color: Colors.red)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("TravelSafe"),
          leading: BackButton(
            color: Colors.white,
            onPressed: _backScreen,
          ),
        ),
        body: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Flexible(
                      child: _friends.isNotEmpty
                          ? ListView.builder(
                              itemCount: _friends.length * 2,
                              padding: const EdgeInsets.all(16),
                              itemBuilder: (context, index) =>
                                  _buildItem(index))
                          : const Text("No friends currently in network"),
                    )
                  ]),
            ),
          ],
        ));
  }
}
