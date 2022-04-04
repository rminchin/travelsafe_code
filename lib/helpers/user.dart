class User {
  String username;
  String password;
  String nickname;

  User(this.username, this.password, this.nickname);

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
    };
  }
}