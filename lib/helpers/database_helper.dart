import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class DatabaseHelper {
  static Future<void> addUserFirebase(User user) async {
    final status = await OneSignal.shared.getDeviceState();
    final String? osUserID = status?.userId;

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .add({
      'username': user.username,
      'password': user.password,
      'nickname': user.nickname,
      'tokenId': osUserID,
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  static Future<Map<String, dynamic>> getUserByUsernameFirebase(
      String username) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();

    for (var snapshot in querySnapshot.docs) {
      Map<String, dynamic> data = snapshot.data();
      if (data['username'] == username) {
        return data;
      }
    }

    throw const FormatException();
  }

  static Future<List<Map<String, dynamic>>> findUserFirebase(String username,
      String user) async {
    List<Map<String, dynamic>> matchingUsers = [];
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();

    for (var snapshot in querySnapshot.docs) {
      Map<String, dynamic> data = snapshot.data();
      if (data['username'].toLowerCase().contains(username.toLowerCase()) && data['username'] != user) {
        matchingUsers.add(data);
      }
    }
    return matchingUsers;
  }

  static Future<List<Map<String, dynamic>>> getUsersFirebase() async {
    List<Map<String, dynamic>> users = [];
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      users.add(data);
    }
    return users;
  }

  static Future<List<Map<String, dynamic>>> getRequestsReceivedFirebase(
      String username) async {
    List<Map<String, dynamic>> requests = [];
    var collection = FirebaseFirestore.instance.collection('requests');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['to'] == username) {
        requests.add(data);
      }
    }
    return requests;
  }

  static Future<List<Map<String, dynamic>>> getRequestsFirebase(
      String username) async {
    List<Map<String, dynamic>> requests = [];
    var collection = FirebaseFirestore.instance.collection('requests');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['from'] == username || data['to'] == username) {
        requests.add(data);
      }
    }
    return requests;
  }

  static Future<List<Map<String, dynamic>>> getFriendsFirebase(
      String username) async {
    List<Map<String, dynamic>> friends = [];
    var collection = FirebaseFirestore.instance.collection('friends');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['user1'] == username || data['user2'] == username) {
        friends.add(data);
      }
    }
    return friends;
  }

  static Future<void> sendRequestFirebase(String from, String to, String nick) async {
    CollectionReference users = FirebaseFirestore.instance.collection(
        'requests');
    return users
        .add({
      'from': from,
      'to': to,
      'from_nickname': nick
    })
        .then((value) => print("Request sent"))
        .catchError((error) => print("Failed to send request: $error"));
  }

  static Future<void> acceptFriendFirebase(String from, String to, String from_nick,
      String to_nick) async {
    CollectionReference friends = FirebaseFirestore.instance.collection(
        'friends');
    var currentDate = DateTime.now();
    final DateFormat formatter = DateFormat('yMMMM');
    final String formatted = formatter.format(currentDate);
    await removeRequestFirebase(from, to);
    return friends
        .add({
      'user1': from,
      'user2': to,
      'user1_nickname': from_nick,
      'user2_nickname': to_nick,
      'since': formatted,
    })
        .then((value) => print("Friend added"))
        .catchError((error) => print("Failed to add friend: $error"));
  }

  static Future<void> removeRequestFirebase(String from, String to) async {
    final collection = FirebaseFirestore.instance.collection('requests');
    String id = await getRequestIDFirebase(from, to);
    collection
        .doc(id)
        .delete()
        .then((_) => print('Request removed'))
        .catchError((error) => print('Removal failed: $error'));
  }

  static Future<String> getIDFirebase(String username) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['username'] == username) {
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<String> getRequestIDFirebase(String from, String to) async {
    var collection = FirebaseFirestore.instance.collection('requests');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['from'] == from && data['to'] == to) {
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<String> getFriendIDFirebase(String user1, String user2) async {
    var collection = FirebaseFirestore.instance.collection('friends');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if ((data['user1'] == user1 && data['user2'] == user2) || (data['user1'] == user2 && data['user2'] == user1)) {
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<void> updateUserFirebase(String old, String username,
      String password, String nickname) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String id = await getIDFirebase(old);
    return users.doc(id)
        .update({
      'username': username,
      'password': password,
      'nickname': nickname
    })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  static Future<void> deleteUserFirebase(String username) async {
    final collection = FirebaseFirestore.instance.collection('users');
    String id = await getIDFirebase(username);
    collection
        .doc(id)
        .delete()
        .then((_) => print('User Deleted'))
        .catchError((error) => print('Delete failed: $error'));
  }

  static Future<void> removeFriendFirebase(String username, String other) async {
    final collection = FirebaseFirestore.instance.collection('friends');
    String id = await getFriendIDFirebase(username, other);
    collection
        .doc(id)
        .delete()
        .then((_) => print('Friendship removed'))
        .catchError((error) => print('Removal failed: $error'));
  }
}