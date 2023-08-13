import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_setup/src/constants/text_strings.dart';
import 'package:login_setup/src/features/authentication/controllers/helper_copntroller.dart';
import 'package:login_setup/src/repository/authentication_repository/authentication_repository.dart';


class LoginController extends GetxController {
  static LoginController get instance => Get.find();
  //textfield Controllers to get data from TextFielders
  final showPassword = false.obs;
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

  //Loader
  final isLoading = false.obs;
  final isGoogleLoading = false.obs;

  //EmailAndpasswordLogin
  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      if (!loginFormKey.currentState!.validate()) {
        isLoading.value = false;
        return;
      }
      final auth = AuthenticationRepository.instance;
      await auth.LoginWithEmailAndPAssword(email, password);
    } catch (e) {
      isLoading.value = false;
      Helper.errorSnackBar(title: tOhSnap, message: e.toString());
    }
  }

  //[GoogleSignInAuthntication]
  Future<void> googleSignIn() async {
    try {
      isGoogleLoading.value = true;
      final auth = AuthenticationRepository.instance;
      await auth.signInWthGoogle();
      isGoogleLoading.value = false;
    } catch (e) {
      isGoogleLoading.value = false;
      Helper.errorSnackBar(title: tOhSnap, message: e.toString());
    }
  }
}
