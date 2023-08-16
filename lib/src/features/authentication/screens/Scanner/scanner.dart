import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  State<Scanner> createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  late String currentuser;
  final GlobalKey qrKey = GlobalKey(debugLabel: "QR");
  QRViewController? controller;
  String result = "";

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    currentuser = FirebaseAuth.instance.currentUser!.uid;
  }

  void _requestLocationPermission() async {
    final PermissionStatus permissionStatus =
        await Permission.location.request();
    if (permissionStatus.isGranted) {
      print("Location permission granted");
    } else {
      print("Location permission denied");
    }
  }

  void _onQrViewCreated(QRViewController controller) async {
    this.controller = controller;
    print('qr code scanned');
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData.code!;
      });

      // Request location permission
    });
  }

  void insert_log() async {
    if (await Permission.location.isGranted) {
      // Get user's current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);

      // Get formatted date and time
      String dateTimeNow =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

      // Get location name using your own implementation
      String locationName =
          await getLocationName(position.latitude, position.longitude);

      "Date & Time: $dateTimeNow";
      double latitude = position.latitude;
      double longitude = position.longitude;
      String time = dateTimeNow;
      String uid = currentuser;
      String locName = locationName;

      final response = await http
          .post(Uri.parse("http://172.20.10.2/api/insert_user_log.php"), body: {
        'latitude': latitude.toString(),
        'uid': uid.toString(),
        'longitude': longitude.toString(),
        'time': time.toString(),
        'locName': locName
      });

      if (response.statusCode == 200) {
        // Successful insertion
        print('Rating inserted successfully!');
      } else {
        // Failed insertion
        print('Failed to insert rating.${response.statusCode}');
      }
    } else {
      // Handle permission denial
      print("Location permission denied.");
    }
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0]; // Get the first placemark

        String address = placemark.name ?? '';
        // if (placemark.thoroughfare != null) {
        //   address += ', ${placemark.thoroughfare}';
        // }
        if (placemark.subThoroughfare != null) {
          address += ', ${placemark.subThoroughfare}';
        }
        if (placemark.locality != null) {
          address += ', ${placemark.locality}';
        }
        if (placemark.administrativeArea != null) {
          address += ', ${placemark.administrativeArea}';
        }
        if (placemark.country != null) {
          address += ', ${placemark.country}';
        }

        return address;
      }
    } catch (e) {
      print("Error fetching location name: $e");
    }

    return "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Scanner"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Dismissible(
            key: Key('dismissKey'), // Unique key for Dismissible
            direction: DismissDirection.down,
            onDismissed: (direction) {
              // Handle dismissal if needed
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 10),
              color: Colors.amber, // Customize the alert color
              child: Center(
                child: Text(
                  "Scan any QR code to save travel log!!!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 25),
          Container(
            height: MediaQuery.of(context).size.height *
                0.6, // Limit the size of the QR scanner
            child: QRView(key: qrKey, onQRViewCreated: _onQrViewCreated),
          ),
          SizedBox(height: 16),
          Text(
            "Scan Result: $result",
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center, // Center the buttons
            children: [
              ElevatedButton(
                onPressed: () {
                  if (result.isNotEmpty) {
                    insert_log();
                  }
                },
                child: Text("Done"),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () async {
                  if (result.isNotEmpty) {
                    final Uri _url = Uri.parse(result);
                    await launchUrl(_url);
                  }
                },
                child: Text("Open"),
              ),
            ],
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
