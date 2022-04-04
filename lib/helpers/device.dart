class Device {
  String deviceId;
  String username;
  int autoLogin;

  Device(this.deviceId, this.username, this.autoLogin);

  Map<String, dynamic> toMap() {
    return {
      'device_id': deviceId,
      'username': username,
      'autoLogin': autoLogin,
    };
  }
}