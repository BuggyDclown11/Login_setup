import 'package:get/get.dart';
import 'package:login_setup/src/features/authentication/screens/welcome%20copy/welcome_view.dart';

class SplashScreenController extends GetxController {
  static SplashScreenController get find => Get.find();
  RxBool animate = false.obs;
  Future startAnuimation() async {
    await Future.delayed(Duration(milliseconds: 500));
    animate.value = true;
    await Future.delayed(Duration(milliseconds: 5000));
    Get.to(WelcomeView());
  }
}
