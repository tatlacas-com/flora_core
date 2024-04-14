abstract class IPreferenceStorage {
  Future<T?> read<T>({required String key});
  Future<T?> delete<T>({required String key});
  Future<void> write<T>({
    required String key,
    required T value,
    Map<String, dynamic>? additionalData,
  });
}
