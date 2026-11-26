import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../models/user_model.dart';

// Defines the operations for accessing user data.
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(String userId);
  Future<User?> login(String email, String password);
  Future<User?> signUp(
  String firstName,
  String lastName,
  String email,
  String password,
);
}

// Temporary repository using local JSON data.
class MockUserRepository implements UserRepository {
  List<User>? _users;

  // Load users from JSON only once per repository instance.
  Future<void> _loadUsers() async {
    if (_users != null) return;

    final jsonString = await rootBundle.loadString(
      'lib/data/users.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _users = jsonData
        .map(
          (item) => User.fromMap(
            item as Map<String, dynamic>,
            (item['id'] as String?) ?? '',
          ),
        )
        .toList();
  }
  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  @override
  Future<List<User>> getUsers() async {
    await _loadUsers();
    return List.unmodifiable(_users!);
  }

  @override
  Future<User?> getUserById(String userId) async {
    await _loadUsers();

    for (final user in _users!) {
      if (user.id == userId) {
        return user;
      }
    }

    return null;
  }
  @override
Future<User?> login(String email, String password) async {
  await _loadUsers();

  final enteredEmail = email.trim().toLowerCase();
  final enteredPasswordHash = _hashPassword(password);

  for (final user in _users!) {
    final isSameEmail = user.email.toLowerCase() == enteredEmail;
    //final isSamePassword = user.passwordHash == enteredPasswordHash;

    // if (isSameEmail && isSamePassword) {
    //   return user;
    // }
  }

  return null;
}
@override
Future<User?> signUp(
  String firstName,
  String lastName,
  String email,
  String password,
) async {
  return null;
}
}

class FirebaseUserRepository implements UserRepository {
  final firebase_auth.FirebaseAuth _auth =
      firebase_auth.FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  @override
  Future<User?> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return null;
    }

    final user = User(
      id: firebaseUser.uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      avatar: null,
    );

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(user.toMap());

    return user;
  }

  @override
  Future<User?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return null;
    }

    return getUserById(firebaseUser.uid);
  }

  @override
  Future<User?> getUserById(String userId) async {
    final document = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return User.fromMap(document.data()!, document.id);
  }

  @override
  Future<List<User>> getUsers() async {
    final snapshot = await _firestore
        .collection('users')
        .get();

    return snapshot.docs
        .map(
          (document) => User.fromMap(
            document.data(),
            document.id,
          ),
        )
        .toList();
  }
}

