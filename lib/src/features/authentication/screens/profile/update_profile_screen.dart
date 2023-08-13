import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:login_setup/src/constants/colors.dart';
import 'package:login_setup/src/constants/image_strings.dart';
import 'package:login_setup/src/constants/sizes.dart';
import 'package:login_setup/src/constants/text_strings.dart';
import 'package:login_setup/src/features/authentication/controllers/profile_controller.dart';
import 'package:login_setup/src/features/authentication/models/user_model.dart';
import 'package:login_setup/src/features/authentication/screens/profile/profile_screen.dart';

import '../../../../constants/constants.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  _UpdateProfileScreenState createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final controller = Get.put(ProfileController());
  late ValueNotifier<String?> id;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController fullnameController;
  late TextEditingController phoneNoController;

  @override
  void initState() {
    super.initState();
    id = ValueNotifier<String?>(null);
    emailController = TextEditingController();
    passwordController = TextEditingController();
    fullnameController = TextEditingController();
    phoneNoController = TextEditingController();
    _loadUserData();
  }

  // ...

  @override
  void dispose() {
    id.dispose();
    emailController.dispose();
    passwordController.dispose();
    fullnameController.dispose();
    phoneNoController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await controller.getUserData();
      id.value = user?.id;

      // Set the initial values of the controllers
      fullnameController.text = user?.fullname ?? '';
      emailController.text = user?.email ?? '';
      phoneNoController.text = user?.phoneNo ?? '';
      passwordController.text = user?.password ?? '';
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch user data");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...

    return Scaffold(
      // ...
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Get.to(ProfileScreen());
          },
          icon: const Icon(LineAwesomeIcons.angle_left),
        ),
        title: Text(
          tEditProfile,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(tDefaultSize),
          child: ValueListenableBuilder<String?>(
            valueListenable: id,
            builder: (context, idValue, child) {
              return Column(children: [
                // ...
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image(
                          image: AssetImage(tProfileImage),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: tPrimaryClr,
                        ),
                        child: Icon(
                          LineAwesomeIcons.camera,
                          size: 20,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 50,
                ),
                Form(
                    key: _formKey,
                    child: Column(children: [
                      TextFormField(
                        controller: fullnameController,
                        decoration: InputDecoration(
                          labelText: tFullName,
                          prefixIcon: Icon(LineAwesomeIcons.user),
                        ),
                        onChanged: (value) {
                          if (FocusManager.instance.primaryFocus?.hasFocus ==
                              true) {
                            // Update the controller's value instead of directly setting the text
                            fullnameController.value = TextEditingValue(
                              text: value,
                              selection: fullnameController.value.selection,
                            );
                          }
                        },
                      ),
                      // ...
                      SizedBox(height: tFormHeight - 20),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: tEmail,
                          prefixIcon: Icon(LineAwesomeIcons.envelope_1),
                        ),
                        onChanged: (value) {
                          if (FocusManager.instance.primaryFocus?.hasFocus ==
                              true) {
                            // Update the controller's value instead of directly setting the text
                            emailController.value = TextEditingValue(
                              text: value,
                              selection: emailController.value.selection,
                            );
                          }
                        },
                      ),
                      // ...
                      SizedBox(height: tFormHeight - 20),
                      TextFormField(
                        controller: phoneNoController,
                        decoration: InputDecoration(
                          labelText: tPhoneNo,
                          prefixIcon: Icon(LineAwesomeIcons.phone),
                        ),
                        onChanged: (value) {
                          if (FocusManager.instance.primaryFocus?.hasFocus ==
                              true) {
                            // Update the controller's value instead of directly setting the text
                            phoneNoController.value = TextEditingValue(
                              text: value,
                              selection: phoneNoController.value.selection,
                            );
                          }
                        },
                      ),
                      // ...
                      SizedBox(height: tFormHeight - 20),
                      TextFormField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: tPassword,
                          prefixIcon: Icon(LineAwesomeIcons.fingerprint),
                        ),
                        onChanged: (value) {
                          if (FocusManager.instance.primaryFocus?.hasFocus ==
                              true) {
                            // Update the controller's value instead of directly setting the text
                            passwordController.value = TextEditingValue(
                              text: value,
                              selection: passwordController.value.selection,
                            );
                          }
                        },
                      ),
                      SizedBox(height: tFormHeight - 20),
                      // ...

                      // Form Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            _formKey.currentState?.save();

                            final user = UserModel(
                              id: idValue,
                              email: emailController.text.trim(),
                              password: passwordController.text.trim(),
                              fullname: fullnameController.text.trim(),
                              phoneNo: phoneNoController.text.trim(),
                            );

                            await controller.updateRecord(user);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.kPrimary,
                            side: BorderSide.none,
                            shape: StadiumBorder(),
                          ),
                          child: Text(
                            tEditProfile,
                            style: TextStyle(color: tDarkClr),
                          ),
                        ),
                      ),
                      SizedBox(height: tFormHeight),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: tJoined,
                              style: TextStyle(fontSize: 12),
                              children: [
                                TextSpan(
                                    text: tJoinedAt,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ))
                              ],
                            ),
                          ),

                          // ...
                        ],
                      )
                    ]))
              ]);
            },
          ),
        ),
      ),
    );
  }
}
