import 'package:shared_preferences/shared_preferences.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

class SharedPreferenceStorage implements IPreferenceStorage {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  Future<T?> read<T>({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    if (T == int) {
      return prefs.getInt(key) as T?;
    }
    if (T == double) {
      return prefs.getDouble(key) as T?;
    }
    if (T == bool) {
      return prefs.getBool(key) as T?;
    }
    if (T == DateTime) {
      final value = prefs.getString(key);
      if (value == null) {
        return null;
      }
      return DateTime.tryParse(value) as T?;
    }
    return prefs.getString(key) as T?;
  }

  @override
  Future<void> write<T>(
      {required String key,
      required T value,
      Map<String, dynamic>? additionalData}) async {
    final SharedPreferences prefs = await _prefs;
    if (value is int) {
      prefs.setInt(key, value);
    }
    if (value is double) {
      prefs.setDouble(key, value);
    }
    if (value is bool) {
      prefs.setBool(key, value);
    }
    if (value is DateTime) {
      prefs.setString(key, value.toIso8601String());
    }
    await prefs.setString(key, value.toString());
  }

  @override
  Future<T?> delete<T>({required String key}) async {
    final SharedPreferences prefs = await _prefs;
    final curr = await read<T>(key: key);
    await prefs.remove(key);
    return curr;
  }
}
