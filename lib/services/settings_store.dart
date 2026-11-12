import 'package:shared_preferences/shared_preferences.dart';

class SettingsStore {
  static late SharedPreferences _prefs;
  static Future<void> init() async => _prefs = await SharedPreferences.getInstance();

  static bool get soundEnabled => _prefs.getBool('sound_enabled') ?? true;
  static Future<void> setSoundEnabled(bool v) => _prefs.setBool('sound_enabled', v);
  static double get soundVolume => _prefs.getDouble('sound_volume') ?? 0.85;
  static Future<void> setSoundVolume(double v) => _prefs.setDouble('sound_volume', v);
  static bool get hapticsEnabled => _prefs.getBool('haptics_enabled') ?? true;
  static Future<void> setHapticsEnabled(bool v) => _prefs.setBool('haptics_enabled', v);
  static bool get isArabic => _prefs.getBool('is_arabic') ?? true;
  static Future<void> setArabic(bool v) => _prefs.setBool('is_arabic', v);

  static int get wins => _prefs.getInt('stats_wins') ?? 0;
  static int get losses => _prefs.getInt('stats_losses') ?? 0;
  static int get draws => _prefs.getInt('stats_draws') ?? 0;

  static Future<void> recordWin() => _prefs.setInt('stats_wins', wins + 1);
  static Future<void> recordLoss() => _prefs.setInt('stats_losses', losses + 1);
  static Future<void> recordDraw() => _prefs.setInt('stats_draws', draws + 1);
}
