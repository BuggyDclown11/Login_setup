import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:login_setup/src/constants/constant.dart';

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

  final String apiUrl1 = "http://192.168.1.67/api/insert_TempleRatings.php";
  final String Url = "http://192.168.1.67/api/insert_fav.php";

  late int templeid;
  late String Username;
  late String title;
  final int uid = 931335757;
  late String currentuser;
  late String comment;
  late double rating;
  bool isFavorite = false;

  Future<void> checkFavoriteStatus() async {
    // Perform the necessary check to determine if the place is in favorites
    final String uiid = currentuser;
    final response = await http.get(Uri.parse(
        "http://192.168.1.67/api/insert_fav.php?uid=$uiid&templeid=$templeid"));

    if (response.statusCode == 200) {
      // Check if the response indicates that the place is in favorites
      final bool isFavorite = response.body == '1';
      setState(() {
        this.isFavorite = isFavorite;
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
        Uri.parse("http://192.168.1.67/api/insert_rating.php?title=$title"),
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
        Uri.parse("http://192.168.1.67/api/insert_fav.php?title=$title"),
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
    final String uiid = currentuser;
    final response = await http
        .delete(Uri.parse("$Url?uid=$uiid&templeid=$templeid&title=$title"));
    if (response.statusCode == 200) {
      // Successful removal
      setState(() {
        isFavorite = false; // Update the favorite status after removal
      });
      print('favtemple removed successfully!');
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
                            Row(
                              children: [
                                Text("city",
                                    style: TextStyle(
                                      color:
                                          isDark ? tPrimaryClr : tSecondaryClr,
                                      fontSize: 20,
                                    )),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Text("${widget.placeInfo.city} city",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey
                                            : tSecondaryClr,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text("Deity",
                                    style: TextStyle(
                                      color:
                                          isDark ? tPrimaryClr : tSecondaryClr,
                                      fontSize: 20,
                                    )),
                                SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child: Text("${widget.placeInfo.city} god",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey
                                            : tSecondaryClr,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      )),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              "Give your reviews",
                              style: TextStyle(
                                  color: isDark ? tPrimaryClr : tSecondaryClr,
                                  fontSize: 23,
                                  fontWeight: FontWeight.bold),
                            ),
                            Container(
                              child: Align(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Ratings",
                                      style: TextStyle(
                                        color: isDark
                                            ? Colors.grey
                                            : tSecondaryClr,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                      ),
                                    ),
                                    for (int i = 0; i < starStatus.length; i++)
                                      GestureDetector(
                                        onTap: () {
                                          //print('tapped');
                                          setState(() {
                                            for (int j = 0; j <= i; j++) {
                                              starStatus[j] = true;
                                            }
                                            for (int k = i + 1;
                                                k < starStatus.length;
                                                k++) {
                                              starStatus[k] = false;
                                            }
                                          });
                                          rating = i + 1;
                                        },
                                        child: Icon(
                                          starStatus[i]
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.yellow,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              child: TextField(
                                controller: _commentController,
                                decoration: InputDecoration(
                                  labelText: 'Add a comment',
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
                            SizedBox(
                              height: 20,
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
