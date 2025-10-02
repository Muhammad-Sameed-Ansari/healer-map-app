import 'package:shared_preferences/shared_preferences.dart';

class SharedPreference {
  SharedPreference._privateConstructor();
  static final SharedPreference instance = SharedPreference._privateConstructor();
  static late SharedPreferences _preferences;
  Future init() async => _preferences = await SharedPreferences.getInstance();

  String? getString(String key) => _preferences.getString(key);
  setString(String key, String? value) {
    //debugPrint('key is $key, value is $value');
    _preferences.setString(key, value ?? '');
  }
  clear() => _preferences.clear();

  // Added helper methods (non-breaking)
  // Remove a specific key
  Future<bool> remove(String key) async {
    return _preferences.remove(key);
  }

  // Get all stored keys
  List<String> getAllKeys() {
    return _preferences.getKeys().toList();
  }
}
