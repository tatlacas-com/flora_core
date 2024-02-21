mixin PersistableMixin on Object {
  String get persistableType;
  Map<String, dynamic> toMap();
}
