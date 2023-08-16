import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geolocator/geolocator.dart';

import '../../models/place_modal.dart';

class FilteredLocation {
  final double latitude;
  final double longitude;
  final double distance;
  final String name;
  final String imgurl;
  final String title;
  FilteredLocation({
    required this.distance,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.imgurl,
    required this.title,
  });
}

class LocationScreen {
  late final PlaceInfo placeInfo;
  //late String title = placeInfo.title!;
  late final String url;
  late final String title;
  late double radiusValue = 100.0;
  static List<FilteredLocation> locations = [];

  LocationScreen({required this.title});
  void setlist(List<FilteredLocation> location1) {
    locations = location1;
  }

  Future<void> fetchLocationsFromAPI(double radius) async {
    print('new radiussssss: $radius');
    print('called func');

    Position userPosition = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double userLatitude = userPosition.latitude;
    double userLongitude = userPosition.longitude;
    print(userLatitude);
    print(userLongitude);

    if (title == 'temple') {
      url = 'http://192.168.34.137/api/show_temple.php';
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('got data');

        List<FilteredLocation> fetchedLocations = data.map((item) {
          return FilteredLocation(
            latitude: double.parse(item['Latitude']),
            longitude: double.parse(item['Longitude']),
            // distance: calculateDistance(
            //   userLatitude,
            //   userLongitude,
            //   double.parse(item['Latitude']),
            //   double.parse(item['Longitude']),
            // ),
            distance: calculateDistance(double.parse(item['Latitude']),
                double.parse(item['Longitude'])),
            name: item['Name'],
            imgurl: item['ImageURL'],
            title: '',
          );
        }).toList();

        // Update the value of radius before filtering the locations
        this.radiusValue = radius;

        List<FilteredLocation> filteredLocations =
            await filterLocationsByRadius(fetchedLocations, radius);

        setlist(filteredLocations);
        //print(filteredLocations);
      }
    } else {
      throw Exception('Failed to fetch locations from API');
    }
  }

  // double calculateDistance(
  //   double userLatitude,
  //   double userLongitude,
  //   double locationLatitude,
  //   double locationLongitude,
  // ) {
  //   print(userLatitude);
  //   print(userLongitude);
  //   double distance = Geolocator.distanceBetween(
  //     userLatitude,
  //     userLongitude,
  //     locationLatitude,
  //     locationLongitude,
  //   );
  //   return distance;
  // }
  double calculateDistance(double latitude, double longitude) {
    double distance = Geolocator.distanceBetween(
      27.67183690973489,
      85.42903234436557,
      latitude,
      longitude,
    );
    return distance;
  }

  List<FilteredLocation> filterLocationsByRadius(
      List<FilteredLocation> allLocations, double radius) {
    List<FilteredLocation> filteredLocations = [];

    for (var location in allLocations) {
      if (location.distance <= radius) {
        filteredLocations.add(location);
      }
    }

    return filteredLocations;
  }

  List<FilteredLocation> returnfilteredLocations() {
    //fetchLocationsFromAPI();
    return locations;
  }
}
