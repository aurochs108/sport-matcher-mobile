import 'package:shared_preferences/shared_preferences.dart';

class ProfileIdStore {
  static const _profileIdKey = 'profile_id';

  Future<void> save(String profileId) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_profileIdKey, profileId);
  }

  Future<String?> load() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_profileIdKey);
  }
}
