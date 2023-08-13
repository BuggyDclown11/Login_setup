
import 'package:flutter/material.dart';

import '../../../../constants/colors.dart';


class About extends StatefulWidget {
  const About({Key? key}) : super(key: key);

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  void initState() {
    super.initState();
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
                                  color: Colors
                                      .purple, // Set the background color to purple
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.arrow_back,
                                  color: Colors
                                      .white, // Set the color of the arrow to white
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 50),
                              child: Text(
                                "RoamIfy",
                                style: txtTheme.headlineMedium,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    ///
                    SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: isDark ? tSecondaryClr : tWhiteClr,
                            borderRadius: BorderRadius.circular(30)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  child: Center(
                                    child: Text("About Us",
                                        style: txtTheme.headlineMedium),
                                  ),
                                ),
                                Container(height: 1,
                                  color: Colors.grey,),
                                SizedBox(height: 10,),
                                Container(
                                  child: Text('Our app is your perfect travel companion, offering a wealth of information and resources to plan your trips. From stunning destinations and hidden gems to exciting activities and cultural experiences, we\'ve curated a comprehensive guide that caters to all your travel interests. '),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ))
          ],
        ));
  }
}
