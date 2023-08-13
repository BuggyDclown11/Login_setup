import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:login_setup/src/features/authentication/screens/dashboard/dashboard.dart';
import 'package:login_setup/src/features/authentication/screens/login_screen/login_screen.dart';
import 'package:login_setup/src/features/authentication/screens/splash/splash_view.dart';
import 'package:login_setup/src/features/authentication/screens/welcome_scr/welcome_screen.dart';
import 'package:login_setup/src/repository/authentication_repository/exceptions/signup_email_password_failure.dart';
import 'package:login_setup/src/repository/authentication_repository/exceptions/t_exception.dart';

import '../../features/authentication/screens/forgot_password/forget_password_otp/otp_screen.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();
  //Variables
  final _auth = FirebaseAuth.instance;
  late final Rx<User?> _firebaseUser;
  var verificationId = ''.obs;

  User? get firebaseUser => _firebaseUser.value;
  @override
  void onReady() {
    _firebaseUser = Rx<User?>(_auth.currentUser);
    _firebaseUser.bindStream(_auth.userChanges());
    ever(_firebaseUser, _setInitialScreen);
  }

  _setInitialScreen(User? user) {
    print('user from authentication repo: $user');
    if (user != null) {
      print('User is logged in. Navigating to Dashboard.');
      Get.offAll(() => Dashboard());
    } else {
      print('User is not logged in. Navigating to SplashView.');
      Get.offAll(() => const SplashView());
    }
  }

  void phoneAuthentication(String phoneNo) async {
    await _auth.verifyPhoneNumber(
        phoneNumber: phoneNo,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        codeSent: (verificationId, resendToken) {
          this.verificationId.value = verificationId;
        },
        codeAutoRetrievalTimeout: (verifcationId) {
          this.verificationId.value = verifcationId;
        },
        verificationFailed: (e) {
          if (e.code == 'invalid-phone-number') {
            Get.snackbar('Error', 'The provided phone number is not valid.');
          } else {
            Get.snackbar('Error', 'Something  went wrong. Try again.');
          }
        });
  }

  Future<bool> verifyOTP(String otp) async {
    var credentials = await _auth.signInWithCredential(
        PhoneAuthProvider.credential(
            verificationId: this.verificationId.value, smsCode: otp));
    return credentials.user != null ? true : false;
  }

  Future<void> createUserWithEmailAndPAssword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      Get.to(() => Dashboard());
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailPasswordFailure.code(e.code);
      Get.snackbar('Error', 'FIREBASE AUTH EXCEPTION - ${ex.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailPasswordFailure();
      print('EXCEPTION - ${ex.message}');
      throw ex;
    }
  }

  Future<UserCredential> signInWthGoogle() async {
    try {
      //Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      //obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      //create a new credential
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
//once signed in,return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      final ex = TExceptions.fromCode(e.code);

      throw ex;
    } catch (_) {
      const ex = TExceptions();
      throw ex.message;
    }
  }

  Future<void> LoginWithEmailAndPAssword(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);

      _firebaseUser.value != null
          ? Get.offAll(() => Dashboard())
          : Get.offAll(() => WelcomeScreen());
    } on FirebaseAuthException catch (e) {
      final ex = SignUpWithEmailPasswordFailure.code(e.code);
      Get.snackbar('Error', 'FIREBASE AUTH EXCEPTION - ${ex.message}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent.withOpacity(0.1),
          colorText: Colors.red);
      throw ex;
    } catch (_) {
      const ex = SignUpWithEmailPasswordFailure();
      print('EXCEPTION - ${ex.message}');
      throw ex;
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw e.message!;
    } on FormatException catch (e) {
      throw e.message;
    } catch (e) {
      throw 'unable to logout.try again.';
    }
  }

  //void setInitialScreen(Rx<User?> firebaseUser) {}
}
