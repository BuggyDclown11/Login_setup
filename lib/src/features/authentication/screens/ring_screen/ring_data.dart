import 'package:fab_circular_menu/fab_circular_menu.dart';
import 'package:flutter/material.dart';
import 'package:login_setup/src/features/authentication/screens/ring_screen/ripple_animation.dart';

// Import the RingsWidget class

class RingsPage extends StatefulWidget {
  @override
  State<RingsPage> createState() => _RingsPageState();
}

class _RingsPageState extends State<RingsPage> {
  String Title = 'temple';

  void handleIconPress(String title) {
    setState(() {
      Title = title;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    //handleIconPress('pond');
    // fetchRecommendations();
    // fetchRecommendedRestaurants();
    //title = widget.placeInfo.title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rings'),
      ),
      body: Center(
        child: RingsWidget(selectedTitle: Title),
      ),
      floatingActionButton: FabCircularMenu(
        alignment: Alignment.bottomLeft,
        fabColor: Colors.blue.shade50,
        fabOpenColor: const Color.fromARGB(255, 233, 153, 165),
        fabCloseColor: const Color.fromARGB(255, 105, 174, 111),
        ringDiameter: 250.0,
        ringWidth: 65.0,
        ringColor: Colors.blue.shade50,
        children: [
          IconButton(
            onPressed: () {
              // handleIconPress('Navigation');
            },
            icon: Icon(Icons.navigation),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                Title = 'mus';
              });
              handleIconPress('mus');
            },
            icon: Icon(Icons.museum_sharp),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                Title = 'temple';
              });
              handleIconPress('temple');
              print('temple is called from fab');
              print('title: $Title');
            },
            icon: Icon(Icons.temple_hindu),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                Title = 'pond';
              });
              handleIconPress('pond');
              print('title: $Title');
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
    );
  }
}
