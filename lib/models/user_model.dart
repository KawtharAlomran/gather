class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    return User(
      id: documentId,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      avatar: data['avatar'] as String?,
    );
  }

  // Convert a user object into JSON.
  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
    };
  }
}