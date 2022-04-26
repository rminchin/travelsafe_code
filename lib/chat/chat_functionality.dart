import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:travelsafe_v1/helpers/user.dart';

import '../helpers/database_helper.dart';
import '../screens/homepage.dart';

class NewConversationSearch extends StatefulWidget {
  final User user;
  const NewConversationSearch({Key? key, required this.user}) : super(key: key);

  @override
  NewConversationSearchState createState() => NewConversationSearchState();
}

class NewConversationSearchState extends State<NewConversationSearch> {
  final TextEditingController _controllerSearchbar = TextEditingController();
  final FocusNode _searchFocus = FocusNode();

  List<Map<String, dynamic>> _results = [];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _results = await findResults();
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
                HomePage(user: widget.user, tab: 3)));
  }

  _openChatScreen(String friendUsername, String friendNickname) async {
    await DatabaseHelper.addConversation(widget.user.username, friendUsername,
        widget.user.nickname, friendNickname);
    Map<String, dynamic> user =
        await DatabaseHelper.getUserByUsernameFirebase(friendUsername);
    User user2Found =
        User(user['username'], user['password'], user['nickname']);
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                OpenChat(user: widget.user, user2: user2Found)));
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> newConversation = await findResults();
    setState(() {
      _results = newConversation;
    });
  }

  Future<List<Map<String, dynamic>>> findResults() async {
    List<Map<String, dynamic>> r = await DatabaseHelper.findUserFirebase(
        _controllerSearchbar.text, widget.user.username);
    List<String> friends =
        await DatabaseHelper.getFriendsListFirebase(widget.user.username);
    List<Map<String, dynamic>> conversations =
        await DatabaseHelper.getConversationsFirebase(widget.user.username);
    List<String> users = [];
    List<Map<String, dynamic>> newConversation = [];
    for (Map<String, dynamic> f in conversations) {
      if (f['username1'] == widget.user.username &&
          friends.contains(f['username2'])) {
        users.add(f['username2']);
      } else if (f['username2'] == widget.user.username &&
          friends.contains(f['username1'])) {
        users.add(f['username1']);
      }
    }
    for (Map<String, dynamic> match in r) {
      if (!users.contains(match['username'])) {
        newConversation.add(match);
      }
    }
    return newConversation;
  }

  Widget _buildItem(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    String user = _results[indexToUse]['username'];
    String nick = _results[indexToUse]['nickname'];
    return ListTile(
      title: Text(nick),
      subtitle: Text(user),
      trailing: ElevatedButton.icon(
          icon: const Icon(Icons.chat_bubble_rounded, color: Colors.blueAccent),
          label: const Text('Chat'),
          onPressed: () async {
            _openChatScreen(_results[indexToUse]['username'],
                _results[indexToUse]['nickname']);
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
                          : _results.isNotEmpty
                              ? ListView.builder(
                                  itemCount: _results.length * 2,
                                  padding: const EdgeInsets.all(16),
                                  itemBuilder: (context, index) =>
                                      _buildItem(index))
                              : _controllerSearchbar.text.isEmpty
                                  ? const Text(
                                      'No friends in network to start a new conversation with')
                                  : const Text('No matching friends found'),
                    )
                  ]),
            ),
          ],
        ));
  }
}

class OpenChat extends StatefulWidget {
  final User user;
  final User user2;
  const OpenChat({Key? key, required this.user, required this.user2})
      : super(key: key);

  @override
  OpenChatState createState() => OpenChatState();
}

class OpenChatState extends State<OpenChat> {
  List<Map<String, dynamic>> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  String _conversationId = 'mSsxXkc7g8tx3uuGxI8Y'; //dummy id

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    _conversationId = await DatabaseHelper.findConversation(
        widget.user.username, widget.user2.username);
    _messages = await DatabaseHelper.getMessagesFirebase(_conversationId);
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    setState(() {
      _isComposing = false;
    });
    _focusNode.requestFocus();
    await DatabaseHelper.sendMessage(
        widget.user.username, widget.user2.username, text);
    List<Map<String, dynamic>> m =
        await DatabaseHelper.getMessagesFirebase(_conversationId);
    setState(() {
      _messages = m;
    });
  }

  void _backScreen() {
    Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
            builder: (BuildContext context) =>
                HomePage(user: widget.user, tab: 3)));
  }

  Widget _buildTextComposer() {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textController,
                onChanged: (text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onSubmitted: _isComposing ? _handleSubmitted : null,
                decoration:
                    const InputDecoration.collapsed(hintText: 'Send a message'),
                focusNode: _focusNode,
              ),
            ),
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isComposing
                      ? () => _handleSubmitted(_textController.text)
                      : null,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(int index) {
    if (index.isOdd) {
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    bool sent =
        _messages[indexToUse]['from'] == widget.user.username ? true : false;
    if (sent) {
      return SentMessage(_messages[indexToUse]);
    } else {
      return ReceivedMessage(_messages[indexToUse]);
    }
  }

  Future<void> updateMessages() async {
    List<Map<String, dynamic>> m =
        await DatabaseHelper.getMessagesFirebase(_conversationId);
    setState(() {
      _messages = m;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('newMessages').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          updateMessages();
          return Scaffold(
            appBar: AppBar(
                centerTitle: true,
                title: Text("Chatting with " + widget.user2.nickname),
                leading: BackButton(
                  color: Colors.white,
                  onPressed: _backScreen,
                )),
            body: Flex(direction: Axis.vertical, children: [
              Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                          child: _messages.isNotEmpty
                              ? ListView.builder(
                                  padding: const EdgeInsets.all(8.0),
                                  reverse: true,
                                  itemCount: _messages.length * 2,
                                  itemBuilder: (context, index) =>
                                      _buildMessage(index))
                              : const Text("No messages to show")),
                    ]),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                      decoration:
                          BoxDecoration(color: Theme.of(context).cardColor),
                      child: _buildTextComposer()))
            ]),
          );
        });
  }
}