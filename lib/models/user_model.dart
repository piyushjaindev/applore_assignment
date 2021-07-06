enum UserStatus { unknown, unauthenticated, authenticated }

class UserModel {
  final String? id;
  final UserStatus userStatus;
  UserModel({this.id, required this.userStatus});
}
