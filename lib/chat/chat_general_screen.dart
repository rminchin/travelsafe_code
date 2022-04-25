import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';
import '../helpers/database_helper.dart';
import '../helpers/notification_handler.dart';
import 'chat_functionality.dart';

class ChatScreen extends StatefulWidget {
  final User user;
  const ChatScreen({Key? key, required this.user}) : super(key: key);

  @override
  ChatScreenState createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controllerSearchbar = TextEditingController();
  late NotificationHandler n;

  List<Map<String, dynamic>> _results = [];
  List<Map<String, dynamic>> _conversations = [];

  @override
  void initState() {
    super.initState();
    n = NotificationHandler();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _conversations =
    await DatabaseHelper.getConversationsFirebase(widget.user.username);
  }

  @override
  void dispose() {
    _controllerSearchbar.dispose();
    super.dispose();
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> r = await DatabaseHelper.findUserFirebase(
        _controllerSearchbar.text, widget.user.username);
    setState(() {
      _results = r;
    });
  }

  _openChatScreen(String friend) async {
    Map<String,dynamic> user = await DatabaseHelper.getUserByUsernameFirebase(friend);
    User user2Found = User(user['username'], user['password'], user['nickname']);
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => OpenChat(user: widget.user, user2: user2Found)));
  }

  _createConversation() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) => NewConversationSearch(user: widget.user)));
  }

  Widget _buildItem(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    String user =
    _conversations[indexToUse]['username1'] == widget.user.username
        ? _conversations[indexToUse]['username2']
        : _conversations[indexToUse]['username1'];
    String nick =
    _conversations[indexToUse]['nickname1'] == widget.user.nickname
        ? _conversations[indexToUse]['nickname2']
        : _conversations[indexToUse]['nickname1'];
    return ListTile(
      title: Text(nick),
      subtitle: Text(user),
      trailing: ElevatedButton.icon(
          icon: const Icon(
            Icons.chat_bubble_rounded,
            color: Colors.blueAccent,
          ),
          label: const Text('Chat'),
          onPressed: () {
            _openChatScreen(user);
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
        body: Stack(
            children: <Widget>[
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(iconSize: 40,
                      icon: const Icon(Icons.add_circle, color: Colors.green),
                      onPressed: _createConversation)
              ),
              Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 50),
                          TextFormField(
                            controller: _controllerSearchbar,
                            decoration: const InputDecoration(
                              labelText: 'Filter:',
                              prefixIcon: Icon(Icons.search),
                            ),
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
                                : _conversations.isNotEmpty
                                ? ListView.builder(
                                itemCount: _conversations.length * 2,
                                padding: const EdgeInsets.all(16),
                                itemBuilder: (context, index) =>
                                    _buildItem(index))
                                : _controllerSearchbar.text.isEmpty
                                ? const Text('No conversations found')
                                : const Text(
                                'No matching conversations found'),
                          )
                        ]),
                  ),
                ],
              ),
            ]
        ));
  }
}
