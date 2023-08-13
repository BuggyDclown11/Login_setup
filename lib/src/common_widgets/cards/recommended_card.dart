import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../features/authentication/models/place_modal.dart';

class RecommendedCard extends StatelessWidget {
  final PlaceInfo placeInfo;
  final VoidCallback press;
  final String? imageUrl;
  const RecommendedCard({
    Key? key, // Corrected argument name
    required this.placeInfo,
    required this.press,
    this.imageUrl,
  }) : super(key: key); // Added 'super(key: key)' argument

  @override
  Widget build(BuildContext context) {

    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    print(placeInfo.name);
    return InkWell(
      onTap: press,
      child: Material(
        elevation: 5,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          height: 278,
          width: 220,
          decoration: BoxDecoration(
              color: isDark ? tSecondaryClr : tCardBgClr,
              borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                          fit: BoxFit.cover,
                          image: NetworkImage(placeInfo.imageUrl))),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  placeInfo.name,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(
                  height: 8.0,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: tPrimaryClr,
                    ),
                    Text(
                      placeInfo.address,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
