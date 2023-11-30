import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class UserPreferences {
  static late SharedPreferences preferences;
  static String userId = '';

  // Gera o id do usuário e o armazena no SharedPreferences
  static Future init() async {
    preferences = await SharedPreferences.getInstance();
    String? storedUserId = preferences.getString('userId');
    if (storedUserId == null) {
      userId = const Uuid().v1();
      await setUserId(userId);
    } else {
      userId = storedUserId;
    }
  }

  static Future setUserId(String uuid) async {
    await preferences.setString('userId', uuid);
  }

  static String getUserId() => preferences.getString(userId) ?? '';
}
