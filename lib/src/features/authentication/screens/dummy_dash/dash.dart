import 'dart:async';
import 'dart:convert';
import 'package:geolocator/geolocator.dart' as geolocator;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:login_setup/src/constants/constants.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:login_setup/src/constants/colors.dart';
import 'package:login_setup/src/features/authentication/controllers/profile_controller.dart';
import 'package:login_setup/src/features/authentication/models/place_modal.dart';
import 'package:login_setup/src/features/authentication/models/user_model.dart';

import '../../../../constants/text_strings.dart';
import '../../controllers/helper_copntroller.dart';

class Dash extends StatefulWidget {
  final PlaceInfo placeInfo;

  const Dash({Key? key, required this.placeInfo}) : super(key: key);

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  final String apiKey = ApiString.ApiKey;
  final controller = Get.put(ProfileController());

  List<dynamic> data = [];
  Set<Marker> _markers = {};
  int currentStep = 0;
  Marker? targetLocationMarker;
  LatLng? previousCameraPosition;
  LatLng? currentLocation;
  Marker? currentLocationMarker;

  bool shouldShowMarkerInfoWindow = true;
  LatLng? targetLocation;
  List<LatLng> polyCoordinates = [];
  double minDistanceToUpdate = 10;
  StreamSubscription<Position>? positionStreamSubscription;
  double cameraZoom = 18.0;
  double cameraTilt = 70.0;
  double cameraBearing = 30.0;
  Duration stepDuration = Duration(milliseconds: 1000);
  bool isUserMoving = false;
  bool showPersonIcon = false;
  String targetLocationName = '';
  String Dest = '';

  String _calculateDistance(LatLng source, LatLng target) {
    double distanceInMeters = geolocator.Geolocator.distanceBetween(
      source.latitude,
      source.longitude,
      target.latitude,
      target.longitude,
    );

    return '${(distanceInMeters / 1000).toStringAsFixed(2)} km';
  }

  String _calculateTime(LatLng source, LatLng target) {
    double distanceInMeters = geolocator.Geolocator.distanceBetween(
      source.latitude,
      source.longitude,
      target.latitude,
      target.longitude,
    );

    // Assuming average walking speed is 5 km/h
    double walkingSpeedKmh = 4.5;
    double timeInHours = distanceInMeters / 1000 / walkingSpeedKmh;

    // Convert hours to minutes
    int timeInMinutes = (timeInHours * 60).toInt();

    if (timeInMinutes < 60) {
      return '${timeInMinutes} minutes';
    } else {
      int hours = timeInMinutes ~/ 60;
      int minutes = timeInMinutes % 60;
      return '${hours} hours ${minutes} minutes';
    }
  }

  void startNavigationAnimation() {
    if (polyCoordinates.isNotEmpty) {
      LatLng start = polyCoordinates[0];

      // Animate the camera to the starting point of the route
      myMapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: start,
            zoom: cameraZoom,
            bearing: cameraBearing,
            tilt: cameraTilt,
          ),
        ),
      );

      // Set the navigation icon at the starting point of the route
      setState(() {
        shouldShowMarkerInfoWindow = true;
        _markers.add(Marker(
          markerId: MarkerId('placeLocation'),
          position: start,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor
              .hueOrange), // You can change the color of the icon here
        ));
      });
    }
  }

  void updateTargetLocation(double latitude, double longitude, String name) {
    setState(() {
      Dest = '';
      targetLocation = LatLng(latitude, longitude);
      targetLocationName = name; // Store the target location name here
      targetLocationMarker = Marker(
        markerId: MarkerId('targetLocation'),
        position: LatLng(latitude, longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: name,
        ),
      );
      _markers
          .removeWhere((marker) => marker.markerId.value == 'targetLocation');
      _markers.add(targetLocationMarker!);
    });

    // Set isUserMoving to true when the target location changes
    isUserMoving = true;

    // Update the route to the new target location
    updateRouteToNewLocation(targetLocation!);
  }

  void animateToStartOfRoute() {
    if (polyCoordinates.isNotEmpty) {
      if (myMapController != null && polyCoordinates.isNotEmpty) {
        myMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  polyCoordinates[0], // Use the first point in polyCoordinates
              zoom: cameraZoom,
              bearing: cameraBearing,
              tilt: cameraTilt,
            ),
          ),
        );
      }
    }
  }

  void updateRouteToNewLocation(LatLng newLocation) {
    // Animate the camera to the starting point of the route
    animateToStartOfRoute();

    // Recalculate the route to the new target location
    getPolyPoints(currentLocation!, newLocation);
  }

  void getPolyPoints(LatLng start, LatLng end) async {
    if (start != null && end != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(start.latitude, start.longitude),
        PointLatLng(end.latitude, end.longitude),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          polyCoordinates.clear();
          result.points.forEach((PointLatLng point) =>
              polyCoordinates.add(LatLng(point.latitude, point.longitude)));
          currentStep = 0;
          if (polyCoordinates.length < 2) {
            // Add a dummy point to the polyline if it has less than 2 points
            // to ensure smooth camera animation
            polyCoordinates.add(polyCoordinates[0]);
          }
        });
      }
    }
  }

  Future<void> findCurrentLocation({bool focusCamera = true}) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Helper.errorSnackBar(title: tOhSnap, message: 'Location is disabled');
      return;
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      Helper.errorSnackBar(
          title: tOhSnap,
          message:
              'Location permissions are permanently denied, we cannot request permissions.');

      return;
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        Helper.errorSnackBar(
            title: tOhSnap,
            message:
                'Location permissions are denied (actual value: $permission).');

        return;
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    if (focusCamera && currentLocation != null) {
      myMapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLocation!, 14),
      );
    }
    if (mounted) {
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        currentLocationMarker = Marker(
          markerId: MarkerId('currentLocation'),
          position: currentLocation!,
          icon: BitmapDescriptor.defaultMarker,
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _buildLocationMarkers();
    Dest = widget.placeInfo.name;
    // Set targetLocation to the latitude and longitude received from the previous screen
    targetLocation = LatLng(
      double.parse(widget.placeInfo.latitude),
      double.parse(widget.placeInfo.longitude),
    );
    if (targetLocation != null) {
      targetLocationMarker = Marker(
        markerId: MarkerId('targetLocation'),
        position: targetLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: widget.placeInfo.name,
        ),
      );
      _markers.add(targetLocationMarker!);
    }

    // Now, get the current location and update the route
    findCurrentLocation(focusCamera: false).then((_) {
      if (currentLocation != null) {
        myMapController
            ?.animateCamera(
          CameraUpdate.newLatLngZoom(currentLocation!, 14),
        )
            .then((value) {
          if (shouldShowMarkerInfoWindow) {
            myMapController?.showMarkerInfoWindow(MarkerId('placeLocation'));
          }
          // Update the route when the widget is first initialized
          updateRoute();
        });
      } else {
        // Handle the case where currentLocation is null (e.g., location permission denied)
        // You can show an error message to the user or handle it based on your app's requirements.
      }
    });

    // Listen for location updates
    positionStreamSubscription =
        Geolocator.getPositionStream().listen((Position position) {
      if (currentLocation == null) {
        // If the currentLocation is null, set it for the first time
        setState(() {
          currentLocation = LatLng(position.latitude, position.longitude);
          currentLocationMarker = Marker(
            markerId: MarkerId('currentLocation'),
            position: currentLocation!,
            icon: BitmapDescriptor.defaultMarker,
          );
        });
      } else {
        double distanceInMeters = Geolocator.distanceBetween(
          currentLocation!.latitude,
          currentLocation!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distanceInMeters >= minDistanceToUpdate && isUserMoving) {
          setState(() {
            currentLocation = LatLng(position.latitude, position.longitude);
            currentLocationMarker = Marker(
              markerId: MarkerId('currentLocation'),
              position: currentLocation!,
              icon: BitmapDescriptor.defaultMarker,
            );
          });

          // Reset the isUserMoving flag after animating the camera
          isUserMoving = false;

          // Update the route when the user moves
          updateRoute();
        }
      }
    });
  }

  void updateRoute() async {
    if (currentLocation != null && targetLocation != null) {
      PolylinePoints polylinePoints = PolylinePoints();
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        apiKey,
        PointLatLng(currentLocation!.latitude, currentLocation!.longitude),
        PointLatLng(targetLocation!.latitude, targetLocation!.longitude),
      );

      if (result.points.isNotEmpty) {
        setState(() {
          polyCoordinates.clear();
          result.points.forEach((PointLatLng point) =>
              polyCoordinates.add(LatLng(point.latitude, point.longitude)));
          currentStep = 0;
          if (polyCoordinates.length < 2) {
            // Add a dummy point to the polyline if it has less than 2 points
            // to ensure smooth camera animation
            polyCoordinates.add(polyCoordinates[0]);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    //_animationController.dispose();
    positionStreamSubscription?.cancel();
    super.dispose();
  }

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(27.674499545705945, 85.4390804576704),
    zoom: 18,
  );
  GoogleMapController? myMapController;

  @override
  Widget build(BuildContext context) {
    bool isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 150,
            left: 0,
            right: 0,
            bottom: 0,
            child: GoogleMap(
              zoomControlsEnabled: false,
              onMapCreated: (GoogleMapController controller) {
                myMapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: currentLocation ??
                    _kGooglePlex
                        .target, // Use current location or fallback to the initial position
                zoom: 14, // Adjust the zoom level as per your preference
              ),
              polylines: {
                Polyline(
                  polylineId: PolylineId("route"),
                  points: polyCoordinates,
                  color: tRouteColor,
                  width: 6,
                ),
              },
              markers: _buildLocationMarkers(),
            ),
          ),
          buildProfileTile(controller, isDark),
          buildTextField(isDark),
          buildCurrentLocationIcon(isDark),
          buildNotificationIcon(),
          DraggableScrollableSheet(
            initialChildSize: 0.03, // Initial size of the bottom sheet
            minChildSize: 0.03, // Minimum size of the bottom sheet
            maxChildSize: 0.3, // Maximum size of the bottom sheet
            builder: (context, scrollController) {
              if (polyCoordinates.isEmpty ||
                  currentLocation == null ||
                  targetLocation == null) {
                return CircularProgressIndicator(); // Placeholder or loading state
              }
              String destinationName =
                  Dest.isNotEmpty ? widget.placeInfo.name : targetLocationName;
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      spreadRadius: 4,
                      blurRadius: 10,
                    ),
                  ],
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(12),
                    topLeft: Radius.circular(12),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: Get.width * 0.6,
                        height: 4,
                        color: Colors.black45,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Destination: $destinationName',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Distance: ${_calculateDistance(currentLocation!, targetLocation!)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Estimated Time: ${_calculateTime(currentLocation!, targetLocation!)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () {
                          // Start the navigation animation
                          startNavigationAnimation();
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          'Start Navigation',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  // buildBottomSheet(),
  // Add your bottom sheet content here
  // For example, you can show the destination details or any other relevant information
  // ...

  Widget buildNotificationIcon() {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, left: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.white,
          child: IconButton(
            onPressed: () {
              // Start the navigation animation
              startNavigationAnimation();
            },
            icon: Icon(
              Icons.navigation_rounded,
              color: Color.fromARGB(255, 121, 104, 122),
              size: 25,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(bool isDark) {
    TextEditingController controller = TextEditingController();
    return Positioned(
      top: 170,
      left: 20,
      right: 20,
      child: Container(
        width: Get.width,
        height: 50,
        padding: EdgeInsets.only(left: 15),
        decoration: BoxDecoration(
          color: isDark ? tSecondaryClr : tWhiteClr,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              spreadRadius: 4,
              blurRadius: 10,
            )
          ],
          borderRadius: BorderRadius.circular(8),
        ),
        child: GooglePlaceAutoCompleteTextField(
          textEditingController: controller,
          googleAPIKey: ApiString.ApiKey,
          inputDecoration: InputDecoration(
            hintStyle: TextStyle(
              color: isDark ? tCardBgClr : tDarkClr,
            ),
            hintText: 'Search for a destination',
            prefixIcon: Padding(
              padding: EdgeInsets.only(left: 10),
              child: Icon(
                Icons.search,
                color: isDark ? tCardBgClr : tDarkClr,
              ),
            ),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          debounceTime: 800,
          countries: ["NP"],
          isLatLngRequired: true,
          getPlaceDetailWithLatLng: (Prediction prediction) {
            double lat = double.parse(prediction.lat ?? '0');
            double lng = double.parse(prediction.lng ?? '0');
            FocusScope.of(context).unfocus();

            if (isLocationInBhaktapur(lat, lng)) {
              // Place is in Bhaktapur, update the target location and marker
              updateTargetLocation(lat, lng, prediction.description!);

              controller.text = prediction.description!;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length),
              );
            } else {
              Get.snackbar(
                "Location Not Supported",
                "Selected place is outside Bhaktapur, Nepal.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: Duration(seconds: 3),
              );
            }
          },
          itmClick: (Prediction prediction) {
            double lat = double.parse(prediction.lat ?? '0');
            double lng = double.parse(prediction.lng ?? '0');
            FocusScope.of(context).unfocus();
            if (isLocationInBhaktapur(lat, lng)) {
              // Perform the same action as in getPlaceDetailWithLatLng.
              controller.text = prediction.description!;
              controller.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description!.length),
              );
            }
          },
        ),
      ),
    );
  }

  bool isLocationInBhaktapur(double lat, double lng) {
    // Define the coordinates of Bhaktapur, Nepal
    final LatLng swBound = LatLng(27.6398, 85.4095); // Southwest corner
    final LatLng neBound = LatLng(27.6946, 85.4603); // Northeast corner

    // Check if the location is within the bounds of Bhaktapur
    return lat >= swBound.latitude &&
        lat <= neBound.latitude &&
        lng >= swBound.longitude &&
        lng <= neBound.longitude;
  }

  Set<Marker> _buildLocationMarkers() {
    Set<Marker> markers = {};

    if (currentLocation != null && currentLocationMarker != null) {
      markers.add(currentLocationMarker!);
    }

    if (targetLocation != null && targetLocationMarker != null) {
      markers.add(targetLocationMarker!);
    }

    return markers;
  }

  Widget buildCurrentLocationIcon(bool isDark) {
    return Align(
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 30, right: 8),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: isDark ? tPrimaryClr : Colors.green,
          child: IconButton(
            onPressed: () {
              findCurrentLocation(focusCamera: true);
            },
            icon: Icon(
              Icons.my_location,
              color: tWhiteClr,
            ),
          ),
        ),
      ),
    );
  }
}

Widget buildProfileTile(controller, isDark) {
  return Positioned(
    top: 60,
    left: 20,
    right: 20,
    child: FutureBuilder(
      future: controller.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            UserModel user = snapshot.data as UserModel;
            final fullname = TextEditingController(text: user.fullname);

            return Container(
              width: Get.width,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/images/user.png"),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Good Morning, ',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                              text: fullname.text,
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        "Where are you going?",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Column(
              children: [
                Center(
                  child: Text(snapshot.error.toString()),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    ),
  );
}

Widget buildBottomSheet() {
  return Align(
    alignment: Alignment.bottomCenter,
    child: Container(
      width: Get.width * 0.8,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 4,
            blurRadius: 10,
          ),
        ],
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(12),
          topLeft: Radius.circular(12),
        ),
      ),
      child: Center(
        child: Container(
          width: Get.width * 0.6,
          height: 4,
          color: Colors.black45,
        ),
      ),
    ),
  );
}
