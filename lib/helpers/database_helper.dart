import 'package:location/location.dart';
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

  static Future<List<Map<String, dynamic>>> findUserFirebase(
      String username, String user) async {
    List<Map<String, dynamic>> matchingUsers = [];
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();

    for (var snapshot in querySnapshot.docs) {
      Map<String, dynamic> data = snapshot.data();
      if (data['username'].toLowerCase().contains(username.toLowerCase()) &&
          data['username'] != user) {
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

  static Future<List<String>> getFriendsListFirebase(
      String username) async {
    List<String> friends = [];
    var collection = FirebaseFirestore.instance.collection('friends');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['user1'] == username) {
        friends.add(data['user2']);
      } else if (data['user2'] == username) {
        friends.add(data['user1']);
      }
    }
    return friends;
  }

  static Future<void> sendRequestFirebase(
      String from, String to, String nick) async {
    CollectionReference users =
        FirebaseFirestore.instance.collection('requests');
    return users
        .add({'from': from, 'to': to, 'from_nickname': nick})
        .then((value) => print("Request sent"))
        .catchError((error) => print("Failed to send request: $error"));
  }

  static Future<void> acceptFriendFirebase(
      String from, String to, String fromNick, String toNick) async {
    CollectionReference friends =
        FirebaseFirestore.instance.collection('friends');
    var currentDate = DateTime.now();
    final DateFormat formatter = DateFormat('yMMMM');
    final String formatted = formatter.format(currentDate);
    await removeRequestFirebase(from, to);
    return friends
        .add({
          'user1': from,
          'user2': to,
          'user1_nickname': fromNick,
          'user2_nickname': toNick,
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
      if ((data['user1'] == user1 && data['user2'] == user2) ||
          (data['user1'] == user2 && data['user2'] == user1)) {
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<void> addLocation(
      LocationData loc, String username, String nickname) async {
    CollectionReference location =
        FirebaseFirestore.instance.collection('location');
    return location
        .doc(username)
        .set({
          'latitude': loc.latitude,
          'longitude': loc.longitude,
          'name': nickname
        }, SetOptions(merge: true))
        .then((value) => print("Location added"))
        .catchError((error) => print("Failed to add location: $error"));
  }

  static Future<void> addLocationSelf(
      LocationData loc, String username, String nickname) async {
    CollectionReference location =
    FirebaseFirestore.instance.collection('locationSelf');
    return location
        .doc(username)
        .set({
      'latitude': loc.latitude,
      'longitude': loc.longitude,
      'name': nickname
    }, SetOptions(merge: true))
        .then((value) => print("Location self added"))
        .catchError((error) => print("Failed to add location self: $error"));
  }

  static Future<void> removeLocation(String username) async {
    CollectionReference location =
        FirebaseFirestore.instance.collection('location');
    location
        .doc(username)
        .delete()
        .then((_) => print('Location Deleted'))
        .catchError((error) => print('Deletion failed: $error'));
  }

  static Future<void> removeLocationSelf(String username) async {
    CollectionReference location =
    FirebaseFirestore.instance.collection('locationSelf');
    location
        .doc(username)
        .delete()
        .then((_) => print('Location self Deleted'))
        .catchError((error) => print('Deletion failed: $error'));
  }

  static Future<void> addStreamFirebase(
      String username, String viewer) async {
    CollectionReference document = FirebaseFirestore.instance.collection('stopped');
    return document
        .doc(username)
        .set({'username': username})
        .then((value) => print("Notification added"))
        .catchError((error) => print("Failed to add notification: $error"));
  }

  static Future<bool> findStreamFirebase() async {
    CollectionReference stream = FirebaseFirestore.instance.collection('stopped');
    var querySnapshot = await stream.get();
    return querySnapshot.size > 0 ? true : false;
  }

  static Future<String> getUsernameStreamFirebase() async {
    var collection = FirebaseFirestore.instance.collection('stopped');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      return data['username'];
    }

    throw const FormatException();
  }

  static Future<void> removeStreamFirebase(String username) async {
    CollectionReference document = FirebaseFirestore.instance.collection('stopped');
    document
        .doc(username)
        .delete()
        .then((_) => print('Notification Deleted'))
        .catchError((error) => print('Deletion failed: $error'));

    var collection = FirebaseFirestore.instance.collection('streams');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['streamer'] == username) {
        String id = await getStreamIDFirebase(username, data['viewer']);
        collection
            .doc(id)
            .delete()
            .then((_) => print('Viewer Deleted end of stream'))
            .catchError((error) => print('Deletion failed: $error'));
      }
    }
  }

  static Future<void> addViewerFirebase(String streamer, String viewer) async {
    CollectionReference document = FirebaseFirestore.instance.collection('streams');
    return document
        .add({'streamer': streamer,
              'viewer': viewer})
        .then((value) => print("Viewer added"))
        .catchError((error) => print("Failed to add viewer: $error"));
  }

  static Future<void> removeViewerFirebase(String streamer, String viewer) async {
    CollectionReference document = FirebaseFirestore.instance.collection('streams');
    String id = await getStreamIDFirebase(streamer,viewer);
    return document
        .doc(id)
        .delete()
        .then((_) => print('Viewer Deleted'))
        .catchError((error) => print('Delete failed: $error'));
  }

  static Future<String> getStreamIDFirebase(String streamer, String viewer) async {
    var collection = FirebaseFirestore.instance.collection('streams');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['streamer'] == streamer && data['viewer'] == viewer) {
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<bool> checkStreamingFirebase(String streamer) async {
    var collection = FirebaseFirestore.instance.collection('streams');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['streamer'] == streamer) {
        return true;
      }
    }
    collection = FirebaseFirestore.instance.collection('location');
    querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      if(doc.id == streamer){
        return true;
      }
    }
    return false;
  }

  static Future<List<Map<String, dynamic>>> getViewersFirebase(
      String username) async {
    List<Map<String, dynamic>> viewers = [];
    var collection = FirebaseFirestore.instance.collection('streams');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['streamer'] == username) {
        viewers.add(data);
      }
    }
    return viewers;
  }

  static Future<List<Map<String,dynamic>>> getConversationsFirebase(String username) async {
    List<Map<String, dynamic>> conversations = [];
    var allMessages = FirebaseFirestore.instance.collection('conversations');
    var querySnapshot = await allMessages.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if (data['username1'] == username || data['username2'] == username) {
        conversations.add(data);
      }
    }
    return conversations;
  }

  static Future<void> addConversation(String user1username, String user2username, String user1nickname, String user2nickname) async{
    CollectionReference conversations = FirebaseFirestore.instance.collection('conversations');

    return conversations
        .add({
      'username1': user1username,
      'nickname1': user1nickname,
      'username2': user2username,
      'nickname2': user2nickname,
    })
        .then((value) => print("Conversation Added"))
        .catchError((error) => print("Failed to add conversation: $error"));
  }

  static Future<List<Map<String,dynamic>>> getMessagesFirebase(String id) async {
    List<Map<String, dynamic>> messages = [];

    var messagesFound = FirebaseFirestore.instance
        .collection('conversations')
        .doc(id)
        .collection('messages')
        .orderBy('at', descending: true);

    var querySnapshot = await messagesFound.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      messages.add(data);
    }
    return messages;
  }

  static Future<void> removeMessagesList() async{
    final collection = FirebaseFirestore.instance.collection('newMessages');
    var snapshots = await collection.get();
    for (var doc in snapshots.docs) {
      await doc.reference.delete();
    }
  }

  static Future<void> sendMessage(String from, String to, String content) async {
    String conversationId = await findConversation(from, to);

    FirebaseFirestore.instance
        .collection('conversations')
        .doc(conversationId)
        .collection('messages')
        .add({'from': from, 'to': to, 'at': FieldValue.serverTimestamp(), 'read': 'n', 'content' : content})
    .then((value) => print("Message sent successfully"))
    .catchError((error) => print("Message failed to send: $error"));

    FirebaseFirestore.instance.collection('newMessages').add({
      'from': from, 'to': to, 'at': FieldValue.serverTimestamp(), 'read': 'n', 'content' : content
    })
        .then((value) => print("Message sent successfully"))
        .catchError((error) => print("Message failed to send: $error"));
  }

  static Future<String> findConversation(String user1, String user2) async {
    var collection = FirebaseFirestore.instance.collection('conversations');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if((data['username1'] == user1 && data['username2'] == user2) || (data['username1'] == user2 && data['username2'] == user1)){
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<void> updateUserFirebase(
      String old, String username, String password, String nickname) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String id = await getIDFirebase(old);
    return users
        .doc(id)
        .update(
            {'username': username, 'password': password, 'nickname': nickname})
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

  static Future<void> removeFriendFirebase(
      String username, String other) async {
    final collection = FirebaseFirestore.instance.collection('friends');
    String id = await getFriendIDFirebase(username, other);
    collection
        .doc(id)
        .delete()
        .then((_) => print('Friendship removed'))
        .catchError((error) => print('Removal failed: $error'));
  }
}
