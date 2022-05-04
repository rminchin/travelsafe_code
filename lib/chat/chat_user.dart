import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/notification_handler.dart';
import '../helpers/user.dart';
import '../maps/draw_map.dart';
import '../screens/homepage.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';

class OpenChat extends StatefulWidget {
  final User user2;
  const OpenChat({Key? key, required this.user2}) : super(key: key);

  @override
  OpenChatState createState() => OpenChatState();
}

class OpenChatState extends State<OpenChat> {
  List<Map<String, dynamic>> _messages = [];
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isComposing = false;
  String _conversationId = 'mSsxXkc7g8tx3uuGxI8Y'; //dummy id
  bool _streaming = false;
  List<Widget> _streamingActions = [];
  final loc.Location location = loc.Location();
  late NotificationHandler n;
  bool _opened = false;
  bool _quick = false;
  late Text _titleText = const Text("");
  final List<String> _quickChats = [
    "Getting ready to leave!",
    "Leaving now!",
    "On my way!",
    "Nearly home!",
    "Home safe!",
    "Feeling unsafe",
    "I need assurance",
    "Feeling nervous",
    "Please call me",
    "Watch my location stream",
    "Here for you whatever you need",
    "Glad you got home safe!",
    "Watching your stream now"
  ];

  @override
  void initState() {
    super.initState();
    initializePreference().whenComplete(() {
      setState(() {});
    });
  }

  Future<void> initializePreference() async {
    setState(() {
      _titleText = Text("Chatting with " + widget.user2.username);
    });
    n = NotificationHandler();
    _conversationId = await DatabaseHelper.findConversation(
        globals.user.username, widget.user2.username);
    _messages = await DatabaseHelper.getMessagesFirebase(_conversationId);
    _streamingActions = [
      IconButton(
          icon: const Icon(Icons.near_me),
          onPressed: () async {
            Navigator.pushAndRemoveUntil<void>(
              context,
              MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      DrawMap(username: widget.user2.username)),
              ModalRoute.withName('/'),
            );
          })
    ];
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    _focusNode.dispose();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    if (mounted) {
      setState(() {
        _isComposing = false;
      });
    }
    _focusNode.requestFocus();
    await DatabaseHelper.sendMessage(
        globals.user.username, widget.user2.username, text);
    List<Map<String, dynamic>> m =
        await DatabaseHelper.getMessagesFirebase(_conversationId);
    if (mounted) {
      setState(() {
        _messages = m;
      });
    }
    Map<String, dynamic> u =
        await DatabaseHelper.getUserByUsernameFirebase(widget.user2.username);
    await n.sendNotification([u['tokenId']],
        globals.user.nickname + " has messaged you!", "New message");
    if(_quick && mounted){
      setState(() {
        _quick = false;
      });
    }
  }

  void _quickChat() async {
    _focusNode.unfocus();
    String titleText;
    if (mounted) {
      setState(() {
        if(_quick){
          titleText = "Chatting with " + widget.user2.username;
        } else{
          titleText = "Quick chat";
        }
        _quick = !_quick;
        _titleText = Text(titleText);
      });
    }
  }

  void _backScreen() {
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 3)),
      ModalRoute.withName('/'),
    );
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
                enabled: !_quick,
                onChanged: (text) {
                  if (mounted) {
                    setState(() {
                      _isComposing = text.isNotEmpty;
                    });
                  }
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
                    icon: const Icon(Icons.double_arrow_rounded),
                    onPressed: _quickChat)),
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
        _messages[indexToUse]['from'] == globals.user.username ? true : false;
    if (sent) {
      return _sentMessage(_messages[indexToUse]);
    } else {
      return _receivedMessage(_messages[indexToUse]);
    }
  }

  Widget _buildQuickChat(int index) {
    if (index.isOdd){
      return const Divider();
    }

    int indexToUse = index ~/ 2;
    return ListTile(
      title: Text(_quickChats[indexToUse]),
      trailing: ElevatedButton.icon(
            icon: const Icon(
              Icons.send_rounded,
              color: Colors.blueAccent,
            ),
            label: const Text('Send'),
            onPressed: () {
              _handleSubmitted(_quickChats[indexToUse]);
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
            )),
      );
  }

  Widget _sentMessage(Map<String, dynamic> message) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const SizedBox(), // Dynamic width spacer
          Container(
            constraints: const BoxConstraints(
              maxWidth: 310.0,
            ),
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 5.0,
              bottom: 5.0,
              right: 5.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.orange,
                  Colors.orangeAccent,
                ],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            child: GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      message['content'],
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox()
        ],
      ),
    );
  }

  Widget _receivedMessage(Map<String, dynamic> message) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(),
          Container(
            constraints: const BoxConstraints(
              maxWidth: 310.0,
            ),
            padding: const EdgeInsets.only(
              left: 5.0,
              top: 5.0,
              bottom: 5.0,
              right: 5.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.lightBlue, Colors.lightBlueAccent],
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(40),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    message['content'],
                    textAlign: TextAlign.left,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(), // Dynamic width spacer
        ],
      ),
    );
  }

  Future<void> updateMessages() async {
    List<Map<String, dynamic>> m =
        await DatabaseHelper.getMessagesFirebase(_conversationId);
    if (mounted) {
      setState(() {
        _messages = m;
      });
    }
    await DatabaseHelper.removeMessagesList();
    bool s = await DatabaseHelper.checkStreamingFirebase(widget.user2.username);
    if (s && mounted) {
      setState(() {
        _streaming = true;
      });
    } else if (mounted) {
      setState(() {
        _streaming = false;
      });
    }
    if (!_opened) {
      _opened = true;
      await DatabaseHelper.markMessagesReadFirebase(
          _conversationId, globals.user.username);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async => false,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('newMessages')
                .snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              updateMessages();
              return Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: _titleText,
                  leading: BackButton(
                    color: Colors.white,
                    onPressed: _backScreen,
                  ),
                  actions: _streaming ? _streamingActions : null,
                ),
                body: Flex(direction: Axis.vertical, children: [
                  Expanded(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Flexible(
                              child: _quick
                                  ? ListView.builder(
                                      padding: const EdgeInsets.all(8.0),
                                      itemCount: _quickChats.length * 2,
                                      itemBuilder: (context, index) =>
                                          _buildQuickChat(index))
                                  : _messages.isNotEmpty
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
            }));
  }
}
