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
      'autoLogin': user.autoLogin
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  static Future<Map<String, dynamic>> getUserByUsernameFirebase(String username) async {
    var collection = FirebaseFirestore.instance.collection('users');
    var querySnapshot = await collection
        .where('username', isEqualTo: username)
        .get();

    for (var snapshot in querySnapshot.docs) {
      Map<String, dynamic> data = snapshot.data();
      return data;
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

  static Future<void> updateUserFirebase(String username, String password, String nickname, bool autoLogin) async {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    String id = await getIDFirebase(username);
    return users.doc(id)
        .update({
      'username': username,
      'password': password,
      'nickname': nickname,
      'autoLogin': autoLogin ? 1 : 0,
    })
        .then((value) => print("User Updated"))
        .catchError((error) => print("Failed to update user: $error"));
  }

  static Future<void> deleteUserFirebase(String username) async {
    final collection = FirebaseFirestore.instance.collection('users');
    collection
        .doc('username')
        .delete()
        .then((_) => print('User Deleted'))
        .catchError((error) => print('Delete failed: $error'));
  }
}