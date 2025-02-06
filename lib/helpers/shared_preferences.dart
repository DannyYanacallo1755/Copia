import '../ui/pages/pages.dart';

class Preferences {
  bool _hasPrefereces = false;
  Map<String, dynamic> _preferences = {};

  Future<void> saveData(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
    preferences = {...preferences, key: value};
  }

  Future<void> getpreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (var key in keys) {
      if (key == 'amount') {
        preferences = {...preferences, key: prefs.getDouble(key)};
      } else {
        preferences = {...preferences, key: prefs.getString(key)};
      }
    }
    hasPreferences = preferences.isNotEmpty;
  }

  Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }

  // Método para guardar la última página visitada
  Future<void> saveLastVisitedPage(String pageName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_visited_page', pageName);
    preferences = {...preferences, 'last_visited_page': pageName};
  }

  // Método para recuperar la última página visitada
  Future<void> getLastVisitedPage() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString('last_visited_page') ?? '';
    preferences = {...preferences, 'last_visited_page': value};
  }

  bool get hasPreferences => _hasPrefereces;

  Map<String, dynamic> get preferences => _preferences;

  set hasPreferences(bool value) {
    _hasPrefereces = value;
  }

  set preferences(Map<String, dynamic> value) {
    _preferences = value;
  }
}
