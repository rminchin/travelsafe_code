import 'chat_user.dart';
import '../helpers/database_helper.dart';
import '../helpers/globals.dart' as globals;
import '../helpers/user.dart';
import '../screens/homepage.dart';

import 'package:flutter/material.dart';

import 'dart:async';

class NewConversationSearch extends StatefulWidget {
  const NewConversationSearch({Key? key}) : super(key: key);

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
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => const HomePage(tab: 3)),
      ModalRoute.withName('/'),
    );
  }

  _openChatScreen(String friendUsername, String friendNickname) async {
    await DatabaseHelper.addConversation(globals.user.username, friendUsername,
        globals.user.nickname, friendNickname);
    Map<String, dynamic> user =
        await DatabaseHelper.getUserByUsernameFirebase(friendUsername);
    User user2Found =
        User(user['username'], user['password'], user['nickname']);
    Navigator.pushAndRemoveUntil<void>(
      context,
      MaterialPageRoute<void>(
          builder: (BuildContext context) => OpenChat(user2: user2Found)),
      ModalRoute.withName('/'),
    );
  }

  Future<void> findMatchingUsers() async {
    List<Map<String, dynamic>> newConversation = await findResults();
    if (mounted) {
      setState(() {
        _results = newConversation;
      });
    }
  }

  Future<List<Map<String, dynamic>>> findResults() async {
    List<Map<String, dynamic>> r = await DatabaseHelper.findUserFirebase(
        _controllerSearchbar.text, globals.user.username);
    List<String> friends =
        await DatabaseHelper.getFriendsListFirebase(globals.user.username);
    List<Map<String, dynamic>> conversations =
        await DatabaseHelper.getConversationsFirebase(globals.user.username);
    List<String> users = [];
    List<Map<String, dynamic>> newConversation = [];
    for (Map<String, dynamic> f in conversations) {
      if (f['username1'] == globals.user.username &&
          friends.contains(f['username2'])) {
        users.add(f['username2']);
      } else if (f['username2'] == globals.user.username &&
          friends.contains(f['username1'])) {
        users.add(f['username1']);
      }
    }
    for (Map<String, dynamic> match in r) {
      if (!users.contains(match['username']) &&
          friends.contains(match['username'])) {
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
