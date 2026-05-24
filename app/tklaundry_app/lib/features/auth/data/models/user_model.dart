import 'package:tklaundry_app/features/auth/domain/entities/user.dart';

class UserModel {
  const UserModel({required this.userId, required this.userName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
    );
  }

  final String userId;
  final String userName;

  User toEntity() => User(userId: userId, userName: userName);
}
