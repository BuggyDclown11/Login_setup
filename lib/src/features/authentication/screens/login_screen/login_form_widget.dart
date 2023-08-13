import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:login_setup/src/features/authentication/controllers/signup_controller.dart';
import 'package:login_setup/src/features/authentication/screens/forgot_password/forget_password_options/forget_password_model_bottom_sheet.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';


class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final controller = Get.put(SignUpController());
  bool _obscurePassword = true; // Variable to toggle password visibility

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Container(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: tFormHeight - 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  validator: (String? value) {
                    const pattern =
                        r"(?:[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\.[a-z0-9!#$%&'"
                        r'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-'
                        r'\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*'
                        r'[a-z0-9])?\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\[(?:(?:(2(5[0-5]|[0-4]'
                        r'[0-9])|1[0-9][0-9]|[1-9]?[0-9]))\.){3}(?:(2(5[0-5]|[0-4][0-9])|1[0-9]'
                        r'[0-9]|[1-9]?[0-9])|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\'
                        r'x21-\x5a\x53-\x7f]|\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\])';
                    final regex = RegExp(pattern);

                    return value!.isNotEmpty && !regex.hasMatch(value)
                        ? 'Enter a valid email address'
                        : null;
                  },
                  controller: controller.email,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person_outline_outlined),
                    labelText: tEmail,
                    hintText: tEmail,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                ),
                SizedBox(
                  height: tFormHeight,
                ),
                TextFormField(
                  controller: controller.password,
                  obscureText: _obscurePassword, // Toggle password visibility
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.fingerprint),
                    labelText: tPassword,
                    hintText: tPassword,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: tFormHeight,
                ),
                /******FORGOT PASSWORD********/
                Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                        onPressed: () {
                          ForgetPasswordScreen.buildShowModalBottomSheet(
                              context);
                        },
                        child: Text(tForgotPassword))),
                SizedBox(
                  height: tFormHeight - 20,
                ),
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        onPressed: () {
                          if (!_formKey.currentState!.validate()) {
                            return;
                          } else {
                            SignUpController.instance.LoginUser(
                                controller.email.text.trim(),
                                controller.password.text.trim());
                          }
                        },
                        child: Text(tLogin.toUpperCase())))
              ],
            ),
          ),
        ));
  }
}
