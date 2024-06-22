import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flora_core/flora_core.dart';

class PreferenceStorage implements IPreferenceStorage {
  static const storage = FlutterSecureStorage();

  T? _asCast<T>(String value) {
    if (T == int) {
      return int.tryParse(value) as T?;
    }
    if (T == double) {
      return double.tryParse(value) as T?;
    }
    if (T == bool) {
      return bool.tryParse(value) as T?;
    }
    if (T == DateTime) {
      return DateTime.tryParse(value) as T?;
    }
    return value as T;
  }

  @override
  Future<T?> read<T>({required String key}) async {
    var catched = false;
    try {
      final value = await storage.read(key: key);
      if (value == null) {
        return null;
      }
      return _asCast<T>(value);
    } catch (e) {
      if (!catched) {
        await storage.deleteAll();
        return read(key: key);
      }
    }
  }

  @override
  Future<void> write<T>(
      {required String key,
      required final T value,
      Map<String, dynamic>? additionalData}) async {
    var catched = false;
    IOSOptions? iOptions = IOSOptions.defaultOptions;
    AndroidOptions? aOptions;
    LinuxOptions? lOptions;
    if (additionalData != null) {
      if (additionalData.containsKey('iOptions')) {
        iOptions = additionalData['iOptions'];
      }
      if (additionalData.containsKey('aOptions')) {
        aOptions = additionalData['aOptions'];
      }
      if (additionalData.containsKey('lOptions')) {
        lOptions = additionalData['lOptions'];
      }
    }
    final valueStr =
        value is DateTime ? value.toIso8601String() : value.toString();
    try {
      return await storage.write(
        key: key,
        value: valueStr,
        aOptions: aOptions,
        iOptions: iOptions,
        lOptions: lOptions,
      );
    } catch (e) {
      if (!catched) {
        await storage.deleteAll();
        return write(
          key: key,
          value: value,
          additionalData: additionalData,
        );
      }
    }
  }

  @override
  Future<T?> delete<T>({required String key}) async {
    final curr = await read<T>(key: key);
    await storage.delete(key: key);
    return curr;
  }
}
