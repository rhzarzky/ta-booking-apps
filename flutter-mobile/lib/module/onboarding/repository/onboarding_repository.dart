import 'package:shared_preferences/shared_preferences.dart';

class OnboardingRepository {
  static const String _onboardingKey = 'onboarding_complete';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefes = await SharedPreferences.getInstance();
    await prefes.setBool(_onboardingKey, true);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, false);
  }
}
