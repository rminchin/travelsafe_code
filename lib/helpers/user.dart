class User {
  String username;
  String password;
  String nickname;
  int keepLoggedIn;

  User(this.username, this.password, this.nickname, this.keepLoggedIn);

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
      'keepLoggedIn': keepLoggedIn,
    };
  }
}