import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:login_setup/firebase_options.dart';
import 'package:login_setup/src/constants/app_theme.dart';
import 'package:login_setup/src/features/authentication/controllers/otp_controller.dart';
import 'package:login_setup/src/features/authentication/screens/splash/splash_view.dart';

import 'package:login_setup/src/repository/authentication_repository/authentication_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)
      .then((value) => Get.put(AuthenticationRepository()));
  runApp(ProviderScope(child: MyApp()));
  OTPController();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      builder: (context, child) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: GetMaterialApp(
            title: 'Ngamar',
            debugShowCheckedModeBanner: false,
            scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
            defaultTransition: Transition.fadeIn,
            theme: AppTheme.lightTheme,
            locale: const Locale('en_US'),
            //initialBinding: HomeBinding(),
            home: const SplashView(),
          ),
        );
      },
    );
  }
}


