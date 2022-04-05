import 'user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  static Future<void> addUserFirebase(User user) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return users
        .add({
      'username': user.username,
      'password': user.password,
      'nickname': user.nickname,
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  static Future<Map<String, dynamic>> getUserByUsernameFirebase(String username) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();

    for (var snapshot in querySnapshot.docs) {
      Map<String, dynamic> data = snapshot.data();
      if(data['username'] == username){
        return data;
      }
    }

    throw const FormatException();
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

  static Future<String> getIDFirebase(String username) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection.get();
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> data = doc.data();
      if(data['username'] == username){
        return doc.id;
      }
    }

    throw const FormatException();
  }

  static Future<void> updateUserFirebase(String old, String username, String password, String nickname) async {
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
}