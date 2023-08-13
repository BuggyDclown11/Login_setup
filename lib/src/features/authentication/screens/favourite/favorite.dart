
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../common_widgets/cards/category_card.dart';

import '../../../../constants/colors.dart';
import '../../models/place_modal.dart';
import 'package:http/http.dart' as http;


class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  static List<PlaceInfo> places = [];

  late int templeid;
  late String Username;
  late String title;
  final int uid = 931335757;
  late String currentuser = FirebaseAuth.instance.currentUser!.uid;
  late String comment;
  late double rating;
  bool isFavorite = false;
  List<PlaceInfo> recommendations = [];

  Future<void> checkFavoriteStatus() async {
    // Perform the necessary check to determine if the place is in favorites
    final String uid = currentuser;
    // final response = await http.get(Uri.parse(
    //     "http://192.168.1.65/api/show_favTemple.php?uid=$uid&templeid=$templeid"));

    final response = await http
        .post(Uri.parse("http://192.168.1.65/api/show_favTemple.php"), body: {
      'templeid': templeid.toString(),
      'uid': uid.toString(),
    });

    if (response.statusCode == 200) {
      // Check if the response indicates that the place is in favorites
      final bool isFavorite = response.body == '1';
      setState(() {
        this.isFavorite = isFavorite;
        print('yes');
      });
    } else {
      // Failed to retrieve favorite status
      print('Failed to check favorite status.${response.statusCode}');
    }
  }

  void _insertFavourite() async {
    print('this');
    final String uiid = currentuser;
    final response = await http.post(
        Uri.parse("http://192.168.1.65/api/insert_fav.php?title=$title"),
        body: {
          'uid': uiid.toString(),
          'templeid': templeid.toString(),
        });
    if (response.statusCode == 200) {
      // Successful insertion
      print('favtemple inserted successfully!');
      setState(() {
        isFavorite = true; // Update the favorite status after insertion
      });
    } else {
      // Failed insertionR
      print('Failed to insert Favtemple.${response.statusCode}');
    }
  }

  void _removeFavourite() async {
    final String uid = currentuser;

    final response = await http.post(
      Uri.parse("http://192.168.1.65/api/remove_fav.php"),
      body: {
        'templeid': templeid.toString(),
        'uid': uid,
      },
    );

    if (response.statusCode == 200) {
      // Successful removal
      setState(() {
        isFavorite = false; // Update the favorite status after removal
      });
      print('fav temple removed successfully!');
    } else {
      // Failed removal
      print('Failed to remove Favtemple.${response.statusCode}');
    }
  }

  void settemples() async {
    final String uid = currentuser;
    List<PlaceInfo> favTemple = await PlacesService().getFavTempleDetails(uid);
    print('hohoh');

    setState(() {
      places = [];
      places = favTemple;
      print(places);
    });
  }

  @override
  void initState() {
    super.initState();
    //templeid = widget.placeInfo.id;
    currentuser = FirebaseAuth.instance.currentUser!.uid;
    // title = widget.placeInfo.title;
    checkFavoriteStatus();
    //fetchRecommendations();
    settemples();
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
                      SizedBox(
                          width:
                              10), // Add a gap between the arrow icon and "Favorites"
                      Expanded(
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Favorites",
                            style: txtTheme.headlineMedium,
                          ),
                        ),
                      ),
                      Material(
                        elevation: 5,
                        borderRadius: BorderRadius.circular(100),
                        child: Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: isFavorite
                                  ? IconButton(
                                      icon: Icon(
                                        Icons.favorite,
                                        color: Colors.red,
                                      ),
                                      onPressed: _removeFavourite,
                                    )
                                  : IconButton(
                                      icon: Icon(
                                        Icons.favorite_border,
                                        color: Colors.white,
                                      ),
                                      onPressed: _insertFavourite,
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                ///
                SizedBox(height: MediaQuery.of(context).size.height * 0.05),
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
                              child: Row(
                                children: [
                                  Text("Popular Destinations",
                                      style: txtTheme.headlineMedium),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Container(
                              height: 60,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: [
                                  Row(
                                    children: [
                                      CategoryCard(
                                        press: () {
                                          settemples();
                                        },
                                        image: "assets/images/temple.jpg",
                                        title: "Temples",
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 10,
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
