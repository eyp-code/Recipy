import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _isFirstRunKey = 'is_first_run';

  Future<bool> shouldShowOnboarding() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    return !(preferences.getBool(_isFirstRunKey) ?? false);
  }

  Future<void> completeOnboarding() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();

    await preferences.setBool(_isFirstRunKey, true);
  }
}
