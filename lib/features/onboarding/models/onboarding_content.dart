class OnboardingContent {
  final String title;
  final String description;
  final String imagePath;
  final String? buttonText;

  const OnboardingContent({
    required this.title,
    required this.description,
    required this.imagePath,
    this.buttonText,
  });
}

class OnboardingData {
  static const List<OnboardingContent> screens = [
    OnboardingContent(
      title: 'Welcome to PureFlow',
      description: 'Your trusted partner for clean, safe drinking water at home.',
      imagePath: 'assets/images/onboarding/welcome.png',
    ),
    OnboardingContent(
      title: 'Professional Installation',
      description: 'Our certified technicians will install your RO system with care and precision.',
      imagePath: 'assets/images/onboarding/installation.png',
    ),
    OnboardingContent(
      title: 'Regular Maintenance',
      description: 'We handle all maintenance and filter changes to ensure optimal performance.',
      imagePath: 'assets/images/onboarding/maintenance.png',
    ),
    OnboardingContent(
      title: 'Quality Guaranteed',
      description: 'Enjoy clean, safe drinking water with our comprehensive water quality testing.',
      imagePath: 'assets/images/onboarding/quality.png',
    ),
    OnboardingContent(
      title: 'Ready to Start?',
      description: 'Choose your subscription plan and get started with PureFlow today.',
      imagePath: 'assets/images/onboarding/start.png',
      buttonText: 'Get Started',
    ),
  ];
} 