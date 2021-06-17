class ThemeProperties {
  final String name;
  final int version;

  const ThemeProperties(this.name, this.version);

  @override
  int get hashCode => name.hashCode ^ version.hashCode;

  @override
  String toString() {
    return '$name $version';
  }

  @override
  bool operator ==(Object other) {
    return other is ThemeProperties &&
        other.name == name &&
        other.version == version;
  }
}