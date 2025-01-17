import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../constants/constants.dart';
import '../../models/onboarding.dart';
import '../welcome copy/welcome_view.dart';
import '../widgets/buttons/primary_button.dart';
import '../widgets/gradients/custom_gradient_card.dart';
import 'components/custom_dots_indicator.dart';
import 'components/onboarding_card.dart';


class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(onboardingList[_currentIndex].bgImage),
            fit: BoxFit.cover,
          ),
        ),
        child: CustomGradientCard(
          gradient: AppColors.customOnboardingGradient,
          child: Column(
            children: [
              const Spacer(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: onboardingList.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return OnboardingCard(
                      onboarding: onboardingList[index],
                    );
                  },
                ),
              ),
              SizedBox(height: AppSpacing.twentyVertical),
              CustomDotsIndicator(
                dotsCount: onboardingList.length,
                position: _currentIndex,
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
              PrimaryButton(
                onTap: () {
                  if (_currentIndex == onboardingList.length - 1) {
                    Get.offAll<Widget>(() => const WelcomeView());
                  } else {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastOutSlowIn,
                    );
                  }
                },
                text: 'Continue',
              ),
              SizedBox(height: AppSpacing.thirtyVertical),
            ],
          ),
        ),
      ),
    );
  }
}
