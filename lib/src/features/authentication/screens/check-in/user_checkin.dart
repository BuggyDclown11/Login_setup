import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';
import '../../models/user_log_model.dart';

class CheckIn extends StatefulWidget {
  const CheckIn({Key? key}) : super(key: key);

  @override
  State<CheckIn> createState() => _CheckInState();
}

class _CheckInState extends State<CheckIn> {
  static List<UserLog> places = [];

  @override
  void initState() {
    super.initState();
    setUserLog();
  }

  void setUserLog() async {
    List<UserLog> uuserLog = await UserLogService().getUserLog();
    setState(() {
      places = uuserLog;
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
      backgroundColor: tRouteColor,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Traveller's log",
                            style: txtTheme.headlineSmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? tSecondaryClr : tWhiteClr,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: Center(
                                child: Text("Recently visited locations",
                                    style: txtTheme.headlineSmall),
                              ),
                            ),
                            Container(
                              height: 1,
                              color: Colors.grey,
                            ),
                            // Loop through the fetched places and display details for each
                            for (var userLog in places)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 5),
                                  Text(
                                    "Time: ${userLog.time}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Location: ${userLog.locName}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Latitude: ${userLog.latitude}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Longitude: ${userLog.longitude}",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  SizedBox(height: 10),
                                  Divider(color: Colors.grey),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
