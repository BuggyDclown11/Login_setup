import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:login_setup/src/features/authentication/screens/dummy_dash/dash.dart';

import '../../../../common_widgets/cards/recommended_card.dart';
import '../../../../constants/colors.dart';
import '../../models/place_modal.dart';
import 'package:http/http.dart' as http;

class DetailScreen extends StatefulWidget {
  final PlaceInfo placeInfo;
  const DetailScreen({Key? key, required this.placeInfo}) : super(key: key);

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  List<bool> starStatus = [false, false, false, false, false];
  TextEditingController _commentController = TextEditingController();

  final String apiUrl1 = "http://192.168.34.137/api/insert_TempleRatings.php";
  final String Url = "http://192.168.34.137/api/insert_fav.php";

  late int templeid;
  late String Username;
  late String title;
  final int uid = 931335757;
  late String currentuser;
  late String comment;
  late double rating;
  bool isFavorite = false;
  List<PlaceInfo> recommendations = [];

  void fetchRecommendations() async {
    // if (title == 'temple') {
    var url = 'http://192.168.34.137:5000/predict';
    var body = jsonEncode({'user_id': currentuser});

    var response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print('Recommendations data: $data');

      List<int> recommendationIds = List<int>.from(data);
      print('Number of recommendations: ${recommendationIds.length}');

      List<PlaceInfo> recommendedTemples = [];

      // Initialize the PlacesService class
      PlacesService placesService = PlacesService();

      // Fetch all temples from the API
      List<PlaceInfo> temples = await placesService.getTemples();

      for (int id in recommendationIds) {
        PlaceInfo temple =
            temples.firstWhere((temples) => temples.id == (id + 1));
        if (temple != null) {
          recommendedTemples.add(temple);
        }
      }

      setState(() {
        recommendations = recommendedTemples;
      });
    } else {
      print('Request failed with status: ${response.statusCode}.');
    }
  }

  Future<void> checkFavoriteStatus() async {
    final String uid = currentuser;

    final response = await http
        .post(Uri.parse("http://192.168.34.137/api/show_favTemple.php"), body: {
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

  void _insertRating(double rating) async {
    print('ratinf');
    print(comment);
    final String uiid = currentuser;
    final response = await http.post(
        Uri.parse("http://192.168.34.137/api/insert_rating.php?title=$title"),
        body: {
          'rating': rating.toString(),
          'templeid': templeid.toString(),
          'uid': uiid.toString(),
          'comment': comment,
        });

    if (response.statusCode == 200) {
      // Successful insertion
      print('Rating inserted successfully!');
    } else {
      // Failed insertion
      print('Failed to insert rating.${response.statusCode}');
    }
  }

  void _insertFavourite() async {
    print('this');
    final String uiid = currentuser;
    final response = await http.post(
        Uri.parse("http://192.168.34.137/api/insert_fav.php?title=$title"),
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
      Uri.parse("http://192.168.34.137/api/remove_fav.php"),
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

  @override
  void initState() {
    super.initState();
    templeid = widget.placeInfo.id;
    currentuser = FirebaseAuth.instance.currentUser!.uid;
    title = widget.placeInfo.title;
    checkFavoriteStatus();
    fetchRecommendations();
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Scaffold(
        backgroundColor: tWhiteClr,
        body: Stack(
          children: [
            Image.network(widget.placeInfo.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.5),
            SafeArea(
                child: Column(
              children: [
                /********APPBAR_BUTTON**********/
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Material(
                          elevation: 5,
                          borderRadius: BorderRadius.circular(100),
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(shape: BoxShape.circle),
                              child: Icon(
                                Icons.arrow_back,
                                color: isDark ? tPrimaryClr : tDarkClr,
                                size: 20,
                              ),
                            ),
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
                SizedBox(height: MediaQuery.of(context).size.height * 0.3),
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
                                  for (int i = 0; i < starStatus.length; i++)
                                    Icon(
                                      starStatus[i]
                                          ? Icons.star
                                          : Icons.star_border,
                                      color: Colors.yellow,
                                    ),
                                ],
                              ),
                            ),
                            Text(
                              widget.placeInfo.name,
                              style: TextStyle(
                                  color: isDark ? tPrimaryClr : tSecondaryClr,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: tPrimaryClr,
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(widget.placeInfo.address,
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 20,
                                    )),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Dash(
                                        placeInfo: widget.placeInfo,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  // ignore: deprecated_member_use
                                  primary: Colors
                                      .indigo, // Set the button's background color
                                  onPrimary: Colors
                                      .white, // Set the text and icon color
                                  padding: EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal:
                                          16), // Adjust the button's padding
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        20), // Apply rounded corners
                                    side: BorderSide.none, // Remove the border
                                  ),
                                  elevation:
                                      8, // Add a shadow with higher elevation
                                ),
                                icon: Icon(
                                  Icons.explore, // Set the icon
                                  size: 24, // Adjust the icon size
                                ),
                                label: Text(
                                  'Explore', // Set the button text
                                  style: TextStyle(
                                    fontSize: 18, // Adjust the text size
                                    fontWeight: FontWeight
                                        .bold, // Apply bold font weight
                                    letterSpacing:
                                        1.0, // Add spacing between letters
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Temple Details",
                              style: TextStyle(
                                  color: isDark ? tPrimaryClr : tSecondaryClr,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(widget.placeInfo.desc,
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                )),
                            Divider(
                              height: 5,
                              color: Colors.black,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            SizedBox(height: 20),
                           
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "City",
                                        style: TextStyle(
                                          color: isDark
                                              ? tPrimaryClr
                                              : tSecondaryClr,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${widget.placeInfo.city}",
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey
                                              : tSecondaryClr,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.45,
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        spreadRadius: 2,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Deity",
                                        style: TextStyle(
                                          color: isDark
                                              ? tPrimaryClr
                                              : tSecondaryClr,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        "${widget.placeInfo.city} god",
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.grey
                                              : tSecondaryClr,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              "Give your reviews",
                              style: TextStyle(
                                  color: isDark ? tPrimaryClr : tSecondaryClr,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            ),
                            reviewMethod(isDark),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  "Recommendation",
                                  style: txtTheme.headlineSmall,
                                ),
                              ],
                            ),
                            Container(
                              height: 300,
                              child: ListView.builder(
                                itemCount: recommendations.length,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 15),
                                    child: Expanded(
                                      child: Row(
                                        children: [
                                          RecommendedCard(
                                            placeInfo: recommendations[index],
                                            press: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      DetailScreen(
                                                    placeInfo:
                                                        recommendations[index],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            )
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

  Container reviewMethod(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 2,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Rating:",
                  style: TextStyle(
                    color: isDark ? Colors.white : tSecondaryClr,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                SizedBox(width: 10),
                for (int i = 0; i < starStatus.length; i++)
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        for (int j = 0; j <= i; j++) {
                          starStatus[j] = true;
                        }
                        for (int k = i + 1; k < starStatus.length; k++) {
                          starStatus[k] = false;
                        }
                      });
                      rating = i + 1;
                    },
                    child: Icon(
                      starStatus[i] ? Icons.star : Icons.star_border,
                      color: Colors.yellow,
                    ),
                  ),
              ],
            ),
          ),
          Divider(color: Colors.grey),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Add a comment',
                prefixIcon: Icon(Icons.chat_bubble_outline),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    comment = _commentController.text;
                    // Process the comment as needed (e.g., send it to an API)
                    _insertRating(rating);
                    setState(() {
                      for (int j = 0; j < 5; j++) {
                        starStatus[j] = false;
                      }
                    });
                    _commentController.clear();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
