import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import 'dart:convert';

// Initialize Firebase and set up Firestore to use the emulator
Future<void> initializeFirebase() async {
  FirebaseFirestore.instance.settings = const Settings(
    host: 'localhost:8080',
    sslEnabled: false,
    persistenceEnabled: false,
  );
}

// User schema definition
Map<String, dynamic> userSchema(String uid, String displayName, String email) {
  return {
    'uid': uid,
    'display_name': displayName,
    'email': email,
  };
}

// Function to create some test users
Future<void> createTestUsers() async {
  CollectionReference usersCollection =
      FirebaseFirestore.instance.collection('users');

  var uuid = Uuid();

  List<Map<String, dynamic>> testUsers = [
    userSchema(uuid.v4(), 'Alice Anderson', 'alice.anderson@example.com'),
    userSchema(uuid.v4(), 'Bob Brown', 'bob.brown@example.com'),
    userSchema(uuid.v4(), 'Charlie Clark', 'charlie.clark@example.com'),
  ];

  for (Map<String, dynamic> user in testUsers) {
    // Check if a user with the same email already exists
    QuerySnapshot querySnapshot = await usersCollection
        .where('email', isEqualTo: user['email'])
        .get();

    if (querySnapshot.docs.isEmpty) {
      await usersCollection.doc(user['uid']).set(user);
    }
  }
}

// Function for pretty printing a Map object
void prettyPrint(Map<String, dynamic> json) {
  const JsonEncoder encoder = JsonEncoder.withIndent('  ');
  String prettyString = encoder.convert(json);
  // ignore: avoid_print
  print(prettyString);
}

// Function to get the list of users from Firestore
Future<List<Map<String, dynamic>>> getUsers() async {
  CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  QuerySnapshot querySnapshot = await usersCollection.get();

  List<Map<String, dynamic>> users = querySnapshot.docs.map((doc) {
    return doc.data() as Map<String, dynamic>;
  }).toList();

  for (var user in users) {
    prettyPrint(user);
  }
  
  return users;
}
