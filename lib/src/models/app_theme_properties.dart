import 'package:equatable/equatable.dart';

class ThemeProperties extends Equatable {
  final String name;
  final int version;

  const ThemeProperties(this.name, this.version);

  @override
  String toString() => 'ThemeProperties {name:$name, version:$version}';

  @override
  List<Object?> get props => [name, version];
}
