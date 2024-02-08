import 'package:farm/keys/pref_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefUtil {
  static SharedPreferences? _sharedPreferences;

  factory PrefUtil() => PrefUtil._internal();

  PrefUtil._internal();

  Future<void> init() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
  }

  bool get getUserLoggedIn => _sharedPreferences!.getBool(loggedIn) ?? false;

  set setUserLoggedIn(bool value) {
    _sharedPreferences!.setBool(loggedIn, value);
  }

  String get getUserId => _sharedPreferences!.getString(userId) ?? "";

  set setUserId(String value) {
    _sharedPreferences!.setString(userId, value);
  }
}
