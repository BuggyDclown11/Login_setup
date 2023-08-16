import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:login_setup/src/features/authentication/screens/dashboard/dashboard.dart';

Future<void> _handleSignIn() async {
  final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

  if (googleUser == null) {
    // Handle sign in failure
    Get.snackbar(
      'Error',
      'Failed to sign in with Google',
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    return;
  }

  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final credential = GoogleAuthProvider.credential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  try {
    // Sign in to Firebase with the Google credential
    final UserCredential userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    // Navigate to the dashboard on success
    Get.offAll(Dashboard());
  } on FirebaseAuthException catch (e) {
    if (e.code == 'account-exists-with-different-credential') {
      // Handle the case where the user already exists with a different credential
      Get.snackbar(
        'Error',
        'An account already exists with this email address',
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else if (e.code == 'invalid-credential') {
      // Handle the case where the credential is invalid (e.g. the token is expired)
      Get.snackbar(
        'Error',
        'Invalid Google credentials',
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } else {
      // Handle other errors
      Get.snackbar(
        'Error',
        e.message ?? 'Failed to sign in with Google',
        duration: Duration(seconds: 5),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  } catch (e) {
    // Handle other errors
    Get.snackbar(
      'Error',
      e.toString(),
      duration: Duration(seconds: 5),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
