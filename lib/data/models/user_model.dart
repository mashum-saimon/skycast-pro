import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final int? id;
  final String username;
  final String password;
  final DateTime createdAt;

  const UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password': password,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  @override
  List<Object?> get props => [id, username, password, createdAt];
}
