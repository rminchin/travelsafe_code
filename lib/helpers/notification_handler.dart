import 'package:http/http.dart';

import 'dart:convert';

class NotificationHandler {
  Future<Response> sendNotification(
      List<String> tokenIdList, String contents, String heading) async {
    return await post(
      Uri.parse('https://onesignal.com/api/v1/notifications'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "app_id": '4482ca21-5afa-43f7-8f09-d7b0b7d196f1',
        "include_player_ids": tokenIdList,
        "android_accent_color": "FF9976D2",
        //"small_icon":"ic_stat_onesignal_default",
        "large_icon":
            "https://www.gstatic.com/mobilesdk/160503_mobilesdk/logo/2x/firebase_28dp.png",
        "headings": {"en": heading},
        "contents": {"en": contents},
      }),
    );
  }
}
