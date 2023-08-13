import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:login_setup/src/features/authentication/controllers/login_controller.dart';

import 'package:login_setup/src/features/authentication/screens/signup_screen/signup-screen.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

class LoginFooterWidget extends StatelessWidget {
  const LoginFooterWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('OR'),
        SizedBox(
          height: tFormHeight - 20,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              icon: Image(
                image: AssetImage('assets/images/google.png'),
                width: 20.0,
              ),
              onPressed: controller.isLoading.value
                  ? () {}
                  : controller.isGoogleLoading.value
                      ? () {}
                      : () => controller.googleSignIn(),
              label: Text(tSignInWithGoogle)),
        ),
        SizedBox(
          height: tFormHeight - 20,
        ),
        TextButton(
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => SignupScreen()));
          },
          child: Text.rich(TextSpan(
              text: tDontHaveAnAccount,
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(
                    text: tSignUp.toUpperCase(),
                    style: TextStyle(color: Colors.blue))
              ])),
        ),
      ],
    );
  }
}
