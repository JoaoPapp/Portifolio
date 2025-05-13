enum UserStatus { pending, signed, skipped }

class User {
  final String id;
  final String name;
  final String email;
  UserStatus status;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.status = UserStatus.pending,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == (json['status'] as String),
        orElse: () => UserStatus.pending,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'status': status.toString().split('.').last,
  };
}
