class User {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String? avatar;
  final String passwordHash;

  const User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.avatar,
    required this.passwordHash,
  });

  String get fullName => '$firstName $lastName';

  // Create a user object from JSON data.
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      avatar: json['avatar'] as String?,
      passwordHash: json['passwordHash'] as String,
    );
  }

  // Convert a user object into JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'avatar': avatar,
      'passwordHash': passwordHash,
    };
  }
}
