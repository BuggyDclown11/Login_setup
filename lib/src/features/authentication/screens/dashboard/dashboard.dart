import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:login_setup/src/common_widgets/cards/category_card.dart';
import 'package:login_setup/src/common_widgets/cards/recommended_card.dart';
import 'package:login_setup/src/common_widgets/cards/recommened/recommended_for_event.dart';
import 'package:login_setup/src/constants/colors.dart';
import 'package:login_setup/src/features/authentication/models/place_modal.dart';
import 'package:login_setup/src/features/authentication/screens/Scanner/scanner.dart';
import 'package:login_setup/src/features/authentication/screens/dashboard/widgets/NavButton.dart';
import 'package:login_setup/src/features/authentication/screens/detail_screen/detail_screen.dart';
import 'package:login_setup/src/features/authentication/screens/favourite/favorite.dart';
import 'package:login_setup/src/features/authentication/screens/profile/profile_screen.dart';

import 'package:http/io_client.dart';
import 'dart:io';
import '../detail_screen/details_for_event.dart';
import '../ring_screen/ring_data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Dashboard extends StatefulWidget {
// final PlaceInfo placeInfo;
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  static List<PlaceInfo> places = [];
  List<PlaceInfo> recommendations = [];
  List<PlaceInfo> data = [];

  //late final PlaceInfo placeInfo;
  // late String title;

  static List<PlaceInfo> allEvents = [];
  late String currentuser;
  String searchText = '';
  List<PlaceInfo> recommendedRestaurants = [];

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

  @override
  void initState() {
    super.initState();
    settemples();
    setAllEvents();
    currentuser = FirebaseAuth.instance.currentUser!.uid;
    fetchRecommendations();
    // fetchRecommendedRestaurants();
    //title = widget.placeInfo.title;
  }

  void fetchRecommendedRestaurants() async {
    try {
      List<PlaceInfo> restaurants = await getRestaurantsInBhaktapur();
      setState(() {
        recommendedRestaurants = restaurants;
      });
    } catch (e) {
      print('Error fetching recommended restaurants: $e');
    }
  }

  Future<List<PlaceInfo>> getRestaurantsInBhaktapur() async {
    final apiKey = "AIzaSyCxWUj8p1mc6ctC6BcPHAb6sPYpichInyU";
    double latitude = 27.6726; // Replace with the user's latitude
    double longitude = 85.4285; // Replace with the user's longitude
    final radius = 5000; // Radius in meters (adjust as needed)
    final type = "restaurant"; // Type of place (restaurant in this case)

    var response = await http.get(Uri.parse(
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=$radius&type=$type&key=$apiKey'));

    if (response.statusCode == 200) {
      List<PlaceInfo> restaurants = parseRestaurantData(response.body);
      return restaurants;
    } else {
      throw Exception('Failed to fetch restaurants from the API.');
    }
  }

  List<PlaceInfo> parseRestaurantData(String responseBody) {
    List<dynamic> data = jsonDecode(responseBody);
    List<PlaceInfo> restaurants = [];

    for (var item in data) {
      PlaceInfo restaurant = PlaceInfo(
        id: item['id'],
        name: item['name'],
        address: item['vicinity'],
        city: '', // Add city field if available in the API response
        imageUrl: '', // Set the imageUrl with the constructed URL
        desc: '', // Add desc field if available in the API response
        title: '', // Add title field if available in the API response
        latitude: item['geometry']['location']['lat'].toString(),
        longitude: item['geometry']['location']['lng'].toString(),
      );

      print(restaurant.name);

      restaurants.add(restaurant);
    }

    return restaurants;
  }

  void settemples() async {
    List<PlaceInfo> temples = await PlacesService().getTemples();
    setState(() {
      places = [];
      places = temples;
    });
  }

  void setponds() async {
    List<PlaceInfo> ponds = await PlacesService().getPonds();
    setState(() {
      places = [];
      places = ponds;
    });
  }

  void setchowks() async {
    List<PlaceInfo> chowks = await PlacesService().getchowks();
    setState(() {
      places = [];
      places = chowks;
    });
  }

  void setmeseums() async {
    List<PlaceInfo> meseums = await PlacesService().getmeseums();
    setState(() {
      places = [];
      places = meseums;
    });
  }

  void setstatues() async {
    List<PlaceInfo> statues = await PlacesService().getstatues();
    setState(() {
      places = [];
      places = statues;
    });
  }

  void setAllEvents() async {
    List<PlaceInfo> events = await PlacesService().getAllEvents();
    setState(() {
      allEvents = [];
      allEvents = events;
    });
  }

  void setUpcomingEvents() async {
    List<PlaceInfo> upcomingEvents = await PlacesService().getUpcomingEvents();
    setState(() {
      allEvents = [];
      allEvents = upcomingEvents;
    });
  }

// Defining a function to search in the MySQL database
  Future<List<PlaceInfo>> searchInDatabase(String query) async {
    final apiUrl = 'https://192.168.34.137/api/search.php';

    HttpClient httpClient = HttpClient()
      ..badCertificateCallback =
          ((X509Certificate cert, String host, int port) => true);

    // Create an IOClient with the custom HttpClient
    final ioClient = IOClient(httpClient);

    // Send the HTTP GET request using the IOClient
    final response = await ioClient.get(Uri.parse('$apiUrl?query=$query'));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final responseData = jsonDecode(response.body);

      // Process the response data and create a list of PlaceInfo objects
      List<PlaceInfo> searchResults = responseData.map<PlaceInfo>((data) {
        // Assuming you have a constructor in PlaceInfo that accepts the necessary fields
        return PlaceInfo(
          id: data['TempleID'],
          name: data['Name'], address: data['Address'], city: data['City'],
          desc: data['Description'], imageUrl: data['ImageURL'],
          title: data['title'], latitude: data['Latitude'],
          longitude: data['Longitude'],
          // Add other fields as necessary
        );
      }).toList();

      // Return the search results
      return searchResults;
    } else {
      throw Exception('Failed to search in the database');
    }
  }

// Implemention of the search functionality
  void searchDestination(String query) {
    print('hello');
    print(query);

    // Call the function to search in the MySQL database
    searchInDatabase(query).then((List<PlaceInfo> results) {
      // Process the search results
      setState(() {
        data = results;
      });
    }).catchError((error) {
      // Handle any errors that occur during the search process
      print('Search error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final txtTheme = Theme.of(context).textTheme;
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    //print(places[0].name);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              NavButton(
                  onPress: () => Get.to(ProfileScreen()),
                  icon: Icons.person_outline),
              NavButton(
                  onPress: () => Get.to(FavoriteScreen()),
                  icon: Icons.favorite_outline),
              NavButton(
                  onPress: () => () => Get.to(Dashboard()),
                  icon: Icons.home,
                  color: Colors.redAccent),
              NavButton(onPress: () => Get.to(RingsPage()), icon: Icons.list),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: ListView(
            children: [
              /*******APP_BAR********/
              Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    backgroundImage: AssetImage("assets/images/user.png"),
                    backgroundColor: isDark ? tSecondaryClr : tAccentClr,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  RichText(
                      text: TextSpan(
                          text: "Hello",
                          style: TextStyle(
                              color: isDark ? tWhiteClr : tDarkClr,
                              fontSize: 18),
                          children: [
                        TextSpan(
                            text: ", Balen",
                            style: TextStyle(
                                color: isDark ? tWhiteClr : tDarkClr,
                                fontWeight: FontWeight.bold,
                                fontSize: 18)),
                      ])),
                  Padding(
                    padding: const EdgeInsets.only(left: 100),
                    child: IconButton(
                      onPressed: () {
                        Get.to(() => Scanner());
                      },
                      icon: Icon(Icons.qr_code),
                      iconSize: 38,
                    ),
                  )
                ],
              ),

              /**********SEARCH_SECTION**********/
              SizedBox(
                height: 15,
              ),
              Text(
                "Explore new destination",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              SizedBox(
                height: 20,
              ),
              searchBar(isDark),
              SizedBox(height: 8),
              if (searchText.isNotEmpty && data.isNotEmpty)
                searchResult(isDark),

              /***************CATEGORY***********/
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text("Popular Destinations", style: txtTheme.headlineSmall),
                ],
              ),
              SizedBox(
                height: 8,
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
                        CategoryCard(
                          press: () {
                            setponds();
                          },
                          image: "assets/images/pond.jpg",
                          title: "Ponds",
                        ),
                        CategoryCard(
                          press: () {
                            setchowks();
                          },
                          image: "assets/images/chwo.webp",
                          title: "chowks",
                        ),
                        CategoryCard(
                          press: () {
                            setmeseums();
                          },
                          image: "assets/images/meu.webp",
                          title: "Mesuems",
                        ),
                        CategoryCard(
                          press: () {
                            setstatues();
                          },
                          image: "assets/images/stat.jpg",
                          title: "Statues",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // SizedBox(
              //   height: 30,
              // ),
              Container(
                height: 308,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: List.generate(
                      (places.length / 2).ceil(),
                      (rowIndex) {
                        final startIndex = rowIndex * 2;
                        final endIndex = (startIndex + 1) < places.length
                            ? startIndex + 1
                            : startIndex;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (startIndex < places.length)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RecommendedCard(
                                    placeInfo: places[startIndex],
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            placeInfo: places[startIndex],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (endIndex < places.length)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RecommendedCard(
                                    placeInfo: places[endIndex],
                                    press: () {
                                      print('zehahah');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailScreen(
                                            placeInfo: places[endIndex],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),

/****************Events****************/
              SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Text(
                    "Events",
                    style: txtTheme.headlineSmall,
                  ),
                ],
              ),
              SizedBox(
                height: 10,
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
                            setAllEvents();
                          },
                          image: "assets/images/temple.jpg",
                          title: "All Events",
                        ),
                        CategoryCard(
                          press: () {
                            setUpcomingEvents();
                          },
                          image: "assets/images/pond.jpg",
                          title: "Upcoming Events",
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Container(
                height: 308,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    children: List.generate(
                      (allEvents.length / 2).ceil(),
                      (rowIndex) {
                        final startIndex = rowIndex * 2;
                        final endIndex = (startIndex + 1) < allEvents.length
                            ? startIndex + 1
                            : startIndex;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            if (startIndex < allEvents.length)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RecommendedForEvent(
                                    placeInfo: allEvents[startIndex],
                                    press: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailForEvent(
                                            placeInfo: allEvents[startIndex],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            if (endIndex < allEvents.length)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RecommendedForEvent(
                                    placeInfo: allEvents[endIndex],
                                    press: () {
                                      print('zehahah');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => DetailForEvent(
                                            placeInfo: allEvents[endIndex],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                      padding: const EdgeInsets.only(left: 5, right: 15),
                      child: Expanded(
                        child: Row(
                          children: [
                            RecommendedCard(
                              placeInfo: recommendations[index],
                              press: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailScreen(
                                      placeInfo: recommendations[index],
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
              ),
              SizedBox(height: 10)
            ],
          ),
        ),
      ),
    );
  }

  Container searchResult(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? tSecondaryClr : Colors.grey.shade100,
        borderRadius:
            BorderRadius.circular(20), // Add this line for rounded corners
      ),
      child: Column(
        children: [
          Text(
            'Search Results',
            style: TextStyle(
              color: isDark ? tCardBgClr : tDarkClr,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Container(
            height: 200,
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: SingleChildScrollView(
              child: ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: data.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      Icons.location_on,
                      size: 20,
                      color: isDark ? tCardBgClr : tDarkClr,
                    ),
                    title: Text(
                      data[index].name,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? tCardBgClr : tDarkClr,
                      ),
                    ),
                    subtitle: Text(
                      data[index].address,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? tCardBgClr : tDarkClr,
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            placeInfo: data[index],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Material searchBar(bool isDark) {
    return Material(
      borderRadius: BorderRadius.circular(100),
      elevation: 5,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? tSecondaryClr : tWhiteClr,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  style: TextStyle(
                    color: isDark ? tPrimaryClr : tDarkClr,
                  ),
                  decoration: InputDecoration(
                    hintText: "Search your destination",
                    prefixIcon: Icon(Icons.search,
                        color: isDark ? tPrimaryClr : tDarkClr),
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: isDark ? tSecondaryClr : tWhiteClr,
                    filled: true,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                    searchDestination(value);
                  },
                ),
              ),
              CircleAvatar(
                radius: 22,
                backgroundColor: tPrimaryClr,
                child: Icon(
                  Icons.sort_by_alpha_sharp,
                  color: tWhiteClr,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
