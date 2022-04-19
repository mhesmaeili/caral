import 'package:shared_preferences/shared_preferences.dart';

class TokenPreferences {
  static const PREF_KEY_TOKEN = "pref_key_token";

  setToken(String value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString(PREF_KEY_TOKEN, value);
  }

  getToken() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getString(PREF_KEY_TOKEN) ?? '';
  }
}
