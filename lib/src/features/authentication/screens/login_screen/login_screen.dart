import 'package:flutter/material.dart';
import 'package:login_setup/src/common_widgets/forms/form_header-widgets.dart';
import 'package:login_setup/src/constants/image_strings.dart';
import 'package:login_setup/src/constants/sizes.dart';
import 'package:login_setup/src/constants/text_strings.dart';
import 'package:login_setup/src/features/authentication/screens/login_screen/login_footer_widget.dart';
import 'package:login_setup/src/features/authentication/screens/login_screen/login_form_widget.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {


    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
              child: Container(
        padding: EdgeInsets.all(tDefaultSize),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          FormHeaderWidget(
              image: tSplashImage,
              title: tLoginTitle,
              subTitle: tLoginSubtitle),
          LoginForm(),
          LoginFooterWidget()
        ]),
      ))),
    );
  }
}
