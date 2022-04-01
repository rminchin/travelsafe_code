class User {
  String username;
  String password;
  String nickname;
  int autoLogin;

  User(this.username, this.password, this.nickname, this.autoLogin);

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'password': password,
      'nickname': nickname,
      'keepLoggedIn': autoLogin,
    };
  }
}