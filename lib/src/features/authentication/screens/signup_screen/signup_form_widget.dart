import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_setup/src/features/authentication/controllers/signup_controller.dart';
import 'package:login_setup/src/features/authentication/models/user_model.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';

extension extString on String {
  bool get isvalidPhone {
    final phoneRegExp = RegExp(r"^\+?0[0-9]{10}[+]$");
    return phoneRegExp.hasMatch(this);
  }

  bool get isValidEmail {
    final emailRegExp = RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    return emailRegExp.hasMatch(this);
  }
}

class SignUpFormWidget extends StatelessWidget {
  const SignUpFormWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignUpController());
    final _formKey = GlobalKey<FormState>();
    controller.fullName.clear();
    controller.email.clear();
    controller.phoneNo.clear();
    controller.password.clear();
    return Container(
      padding: EdgeInsets.symmetric(vertical: tFormHeight - 10),
      child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: controller.fullName,
                validator: (String? input) {
                  if (input!.isEmpty) {
                    return 'Name is required.';
                  }
                  if (input.length < 5) {
                    return 'Please enter a valid Name';
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                    label: Text(tFullName),
                    prefixIcon: Icon(Icons.person_outline_rounded)),
              ),
              SizedBox(
                height: tFormHeight - 20,
              ),
              TextFormField(
                validator: (String? value) {
                  if (!value!.isValidEmail) return 'Enter valid email';
                  if (value.isEmpty) {
                    return 'Please enter email';
                  } else {
                    return null;
                  }
                },
                controller: controller.email,
                decoration: InputDecoration(
                    label: Text(tEmail),
                    prefixIcon: Icon(Icons.email_outlined)),
              ),
              SizedBox(
                height: tFormHeight - 20,
              ),
              TextFormField(
                validator: (String? input) {
                  if (input!.isEmpty) {
                    return 'Enter  Phone number';
                  }
                  if (input.length < 13) {
                    return 'Please enter PhoneNo Starting with country code';
                  } else {
                    return null;
                  }
                },
                controller: controller.phoneNo,
                decoration: InputDecoration(
                    label: Text(tPhoneNo), prefixIcon: Icon(Icons.numbers)),
              ),
              SizedBox(
                height: tFormHeight - 20,
              ),
              TextFormField(
                validator: (String? input) {
                  if (input!.isEmpty) {
                    return 'Password is required.';
                  }
                  if (input.length < 8) {
                    return 'Please enter a password with length>8';
                  } else {
                    return null;
                  }
                },
                controller: controller.password,
                decoration: InputDecoration(
                    label: Text(tPassword),
                    prefixIcon: Icon(Icons.fingerprint)),
              ),
              const SizedBox(
                height: tFormHeight - 10,
              ),
              SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                      onPressed: () {
                        if (!_formKey.currentState!.validate()) {
                      
                          return;
                        } else {
                          final user = UserModel(
                              email: controller.email.text.trim(),
                              password: controller.password.text.trim(),
                              fullname: controller.fullName.text.trim(),
                              phoneNo: controller.phoneNo.text.trim());

                          SignUpController.instance.createUser(user);
                        }
                      },
                      child: Text(tSignUp.toUpperCase())))
            ],
          )),
    );
  }
}
