class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}


// 임시 사용자 리스트 (나중엔 DB로 대체)
List<User> registeredUsers = [];