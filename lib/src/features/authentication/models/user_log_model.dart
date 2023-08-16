import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserLog {
  final String time, locName, latitude, longitude;
  final int id;

  UserLog({
    required this.id,
    required this.time,
    required this.locName,
    required this.latitude,
    required this.longitude,
  });

  factory UserLog.fromJson(Map<String, dynamic> json) {
    return UserLog(
      id: json['UserID'] ?? 0,
      time: json['Time'] ?? '',
      locName: json['locationName'] ?? '',
      latitude: json['Latitude'] ?? '',
      longitude: json['Longitude'] ?? '',
    );
  }
}

class UserLogService {
  // List<PlaceInfo> places = [];
  Future<List<UserLog>> getUserLog() async {
    List<UserLog> userLog = [];
    String uid = FirebaseAuth.instance.currentUser!.uid;
    final String url = 'http://192.168.34.137/api/show_user_log.php';

    var response = await http.post(Uri.parse(url), body: {'uid': uid});
    if (response.statusCode == 200) {
      print('Success in fetching user log\n');
    } else {
      print('faaaileddddddddddddddddddddddddd');
    }
    var results = jsonDecode(response.body);

    for (var result in results) {
      UserLog log = UserLog.fromJson(result);
      userLog.add(log);
    }

    return userLog;
  }
}
