
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
import 'package:flutter/services.dart';

import '../../models/user_model.dart';

// Defines the operations for accessing user data.
abstract class UserRepository {
  Future<List<User>> getUsers();

  Future<User?> getUserById(String userId);

  Future<User?> findUserByEmail(String email);

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

  // Search local sample users by exact email.
  @override
  Future<User?> findUserByEmail(String email) async {
    await _loadUsers();

    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users!) {
      if (user.email.trim().toLowerCase() ==
          normalizedEmail) {
        return user;
      }
    }

    return null;
  }

  // Authentication is not supported by the mock repository.
  @override
  Future<User?> login(
    String email,
    String password,
  ) async {
    throw UnsupportedError(
      'Use FirebaseUserRepository for authentication.',
    );
  }

  @override
  Future<User?> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    throw UnsupportedError(
      'Use FirebaseUserRepository for registration.',
    );
  }
}

// Firebase implementation of UserRepository.
class FirebaseUserRepository implements UserRepository {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirebaseUserRepository({
    firebase_auth.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // Normalize emails for consistent searching.
  String _normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Register a user and save their profile.
  @override
  Future<User?> signUp(
    String firstName,
    String lastName,
    String email,
    String password,
  ) async {
    final normalizedEmail = _normalizeEmail(email);

    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw StateError('Unable to create user account.');
    }

    final user = User(
      id: firebaseUser.uid,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: normalizedEmail,
      avatar: null,
    );

    final batch = _firestore.batch();

    final userRef = _firestore
        .collection('users')
        .doc(firebaseUser.uid);

    final directoryRef = _firestore
        .collection('user_directory')
        .doc(firebaseUser.uid);

    // Save the private user profile.
    batch.set(userRef, user.toMap());

    // Save limited searchable account information.
    batch.set(directoryRef, {
      'displayName':
          '${firstName.trim()} ${lastName.trim()}',
      'email': normalizedEmail,
      'searchable': true,
    });

    // Save both documents atomically.
    await batch.commit();

    return user;
  }

  // Sign in using Firebase Authentication.
  @override
  Future<User?> login(
    String email,
    String password,
  ) async {
    final credential =
        await _auth.signInWithEmailAndPassword(
      email: _normalizeEmail(email),
      password: password,
    );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      return null;
    }

    return getUserById(firebaseUser.uid);
  }

  // Get a user profile by UID.
  @override
  Future<User?> getUserById(String userId) async {
    final document = await _firestore
        .collection('users')
        .doc(userId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return User.fromMap(
      document.data()!,
      document.id,
    );
  }

  // Search for a registered user by exact email.
  @override
  Future<User?> findUserByEmail(String email) async {
    final normalizedEmail = _normalizeEmail(email);

    if (normalizedEmail.isEmpty) {
      return null;
    }

    final snapshot = await _firestore
        .collection('user_directory')
        .where('email', isEqualTo: normalizedEmail)
        .where('searchable', isEqualTo: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final document = snapshot.docs.first;
    final data = document.data();

    final displayName =
        (data['displayName'] as String? ?? '').trim();

    final nameParts = displayName.split(
      RegExp(r'\s+'),
    );

    final firstName =
        nameParts.isNotEmpty ? nameParts.first : '';

    final lastName = nameParts.length > 1
        ? nameParts.skip(1).join(' ')
        : '';

    return User(
      id: document.id,
      firstName: firstName,
      lastName: lastName,
      email: data['email'] as String? ?? normalizedEmail,
      avatar: null,
    );
  }

  // Return the current user's private profile.
  //
  // This does not enumerate all registered users because
  // their private profiles are protected by Firestore rules.
  @override
  Future<List<User>> getUsers() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('User is not authenticated.');
    }

    final user = await getUserById(currentUser.uid);

    return user == null ? [] : [user];
  }
}

// Notes:
// - Firebase Authentication generates unique user UIDs.
// - Private profiles are stored in users/{uid}.
// - Searchable profiles are stored in user_directory/{uid}.
// - Email searches use exact matching.
// - No hardcoded user IDs are required.
// - Friends functionality will be integrated later.
// - Firestore Security Rules must protect both collections.

