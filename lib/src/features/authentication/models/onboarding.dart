import '../../../constants/app_assets.dart';

class Onboarding {
  String bgImage;
  String title;
  String info;
  Onboarding({
    required this.bgImage,
    required this.title,
    required this.info,
  });
}

List<Onboarding> onboardingList = [
  Onboarding(
    bgImage: AppAssets.kOnboardingFirst,
    title: '"Navigate, Capture, Connect, Discover',
    info:
        'Discover breathtaking destinations, hidden gems, and immersive experiences that will leave you awe-inspired . ',
  ),
  Onboarding(
    bgImage: AppAssets.kOnboardingSecond,
    title: "Connect with Fellow Travelers",
    info:
        'Share tips, exchange stories, and connect with like-minded travelers who share your love for exploration .',
  ),
];
