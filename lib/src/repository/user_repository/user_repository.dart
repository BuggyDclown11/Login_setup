import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:login_setup/src/constants/constants.dart';
import 'package:login_setup/src/features/authentication/models/user_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();

  final _db = FirebaseFirestore.instance;
//Store user in Firebase

  Future<void> createUser(UserModel user) async {
    await _db.collection("Users").add(user.toJson()).then((docRef) async {
      // Get the ID of the newly created document in Firebase
      String userId = FirebaseAuth.instance.currentUser!.uid;

      // Save the user locally using the same user ID
      await _saveUserDataLocally(user, userId);

      Get.snackbar(
        "Success",
        "Your account has been created.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
      );
    }).catchError((error) {
      Get.snackbar(
        "Error",
        "Something went wrong. Try Again",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent.withOpacity(0.1),
        colorText: Colors.red,
      );
      print("ERROR: $error");
    });
  }

  Future<void> _saveUserDataLocally(UserModel user, String userId) async {
    final url = ApiString.insertIntoDB;

    try {
      final response = await http.post(
        Uri.parse(url),
        body: {
          'userId': userId, // Pass the user ID to the PHP script
          'fullname': user.fullname,
          'email': user.email,
          'phoneNo': user.phoneNo,
        },
      );
      print(response.statusCode);
      if (response.statusCode == 200) {
        // User saved locally in MySQL database successfully
        print('User saved locally in MySQL database');
        print(user.fullname);
        print(userId);
      } else {
        // Error occurred while saving user locally in MySQL database
        print(
            'Failed to save user locally in MySQL database. Status code: ${response.statusCode}');
      }
    } catch (e) {
      // Error occurred during the HTTP request
      print('Error occurred while saving user locally in MySQL database: $e');
    }
  }

//Fetch All Users or User Details
  Future<UserModel> getUserDetails(String email) async {
    final snapshot =
        await _db.collection("Users").where("Email", isEqualTo: email).get();
    final userData = snapshot.docs.map((e) => UserModel.fromSnapshot(e)).single;
    return userData;
  }

  Future<List<UserModel>> allUser() async {
    final snapshot = await _db.collection("Users").get();
    final userData =
        snapshot.docs.map((e) => UserModel.fromSnapshot(e)).toList();
    return userData;
  }

  Future<void> updateUserRecord(UserModel user) async {
    await _db.collection("Users").doc(user.id).update(user.toJson());
  }
}
