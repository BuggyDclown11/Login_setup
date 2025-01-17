import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/text_strings.dart';
import '../onboarding/onboarding_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 7), () {
      Get.offAll<Widget>(() => const OnboardingView());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        width: Get.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.kSplashBG),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            const Spacer(),
            SvgPicture.asset(
              AppAssets.kShower,
              height: 64.h,
              width: 64.w,
            ),
            SizedBox(height: AppSpacing.twentyVertical),
            Text(
              'Roamify',
              style: AppTypography.kExtraBold40.copyWith(
                color: Colors.white,
              ),
            ),
            SizedBox(height: AppSpacing.tenVertical),
            Text(
              tWelcomeTitle,
              style: AppTypography.kMedium14.copyWith(
                color: Colors.white,
              ),
            ),
            const Spacer(),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.kWhite),
            ),
            SizedBox(height: 133.h),
          ],
        ),
      ),
    );
  }
}
