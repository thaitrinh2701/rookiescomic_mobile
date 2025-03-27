class User {
  final String userId;
  final String firstName;
  final String lastName;

  User({required this.userId, required this.firstName, required this.lastName});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}
