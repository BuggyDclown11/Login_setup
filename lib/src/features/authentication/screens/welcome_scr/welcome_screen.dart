import 'package:flutter/material.dart';
import 'package:login_setup/src/constants/colors.dart';
import 'package:login_setup/src/constants/image_strings.dart';
import 'package:login_setup/src/constants/sizes.dart';
import 'package:login_setup/src/constants/text_strings.dart';
import 'package:login_setup/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:login_setup/src/features/authentication/screens/signup_screen/signup-screen.dart';
import 'package:lottie/lottie.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var brightness = mediaQuery.platformBrightness;
    final isDarkMode = brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? tSecondaryClr : tPrimaryClr,
      body: Container(
        padding: EdgeInsets.all(tDefaultSize),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Image(
                image: AssetImage(tForgotPasswordImage),
                fit: BoxFit.cover,
                height: height * 0.5),
            Expanded(
              child: Column(
                children: [
                  Text(
                    tWelcomeTitle,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  Text(
                    tWelcomeSubtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => LoginScreen()));
                    },
                    child: Text(tLogin.toUpperCase()),
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => SignupScreen()));
                    },
                    child: Text(tSignUp.toUpperCase()),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
