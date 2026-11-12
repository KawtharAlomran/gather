
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import '../../models/user_model.dart';

// Defines the operations for accessing user data.
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User?> getUserById(String userId);
  Future<User?> login(String email, String password);
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
          (item) => User.fromJson(
            item as Map<String, dynamic>,
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
    final isSamePassword = user.passwordHash == enteredPasswordHash;

    if (isSameEmail && isSamePassword) {
      return user;
    }
  }

  return null;
}
}

// Example usage:
//
// final repository = MockUserRepository();
//
// final users = await repository.getUsers();
//
// final user = await repository.getUserById('user_1');
//
// Notes:
// - User data is shared across all screens.
// - JSON is loaded once per repository instance.
// - The repository can later use API and local caching.
// - Compatible with BLoC, Cubit, or Provider.
