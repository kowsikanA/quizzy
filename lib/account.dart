import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  String? username; 
  String? password;
  DocumentReference? reference; 

  Account({this.username, this.password, this.reference});

  // Will be used to take data from data base and create grade object
  Account.fromMap(Map<String, dynamic> map, {this.reference})
      : username = map['username'] as String?,
        password = map['password'] as String?;

  // Used to create dictionary to be pushed to database
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
    };
  }
}