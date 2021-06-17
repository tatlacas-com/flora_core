abstract class IPreferenceStorage {
  Future<String?> read({required String key});
  Future<String?> delete({required String key});
  Future<void> write({
  required String key,
  required String? value,
  Map<String,dynamic>? additionalData,
  });
}