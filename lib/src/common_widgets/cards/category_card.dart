import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class CategoryCard extends StatelessWidget {
  final String title, image;
  final VoidCallback press;

  const CategoryCard({
    super.key,
    required this.title,
    required this.image,
    required this.press,
  });

  @override
  Widget build(BuildContext context) {
    
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: press,
        child: Material(
          elevation: 5,
          borderRadius: BorderRadius.circular(100),
          child: Container(
            height: 60,
            decoration: BoxDecoration(
              color: !isDark ? tWhiteClr : tSecondaryClr,
              borderRadius: BorderRadius.circular(100),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 15),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: AssetImage(image),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    title,
                    style: TextStyle(color: isDark ? tPrimaryClr : tDarkClr),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
