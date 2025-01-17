import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../../../constants/text_strings.dart';
import '../auth/signin_view.dart';
import '../auth/signup_view.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/gradients/custom_gradient_card.dart';

class WelcomeView extends StatelessWidget {
  const WelcomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.kOnboardingThird),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomGradientCard(
          gradient: AppColors.customOnboardingGradient,
          child: Column(
            children: [
              const Spacer(),
              RichText(
                text: TextSpan(
                  text: tWelcomeTitle,
                  style: AppTypography.kSemiBold24
                      .copyWith(color: AppColors.kWhite),
                  // children: [
                  //   TextSpan(
                  //     text: 'Ngamar.',
                  //     style: AppTypography.kSemiBold24
                  //         .copyWith(color: AppColors.kPrimary),
                  //   ),
                  // ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.tenVertical),
              Text(
                tWelcomeSubtitle,
                textAlign: TextAlign.center,
                style:
                    AppTypography.kMedium14.copyWith(color: AppColors.kWhite),
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              PrimaryButton(
                onTap: () {
                  Get.to<Widget>(() => const SignInView());
                },
                text: 'Get Started',
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              RichText(
                text: TextSpan(
                  text: 'Don’t have an account? ',
                  style: AppTypography.kSemiBold16
                      .copyWith(color: AppColors.kWhite),
                  children: [
                    TextSpan(
                      text: 'Register',
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.to<Widget>(() => const SignUpView());
                        },
                      style: AppTypography.kSemiBold16
                          .copyWith(color: AppColors.kPrimary),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
            ],
          ),
        ),
      ),
    );
  }
}
