import 'package:equatable/equatable.dart';

class ThemeProperties extends Equatable {

  const ThemeProperties(this.name, this.version);
  final String name;
  final int version;

  @override
  String toString() => 'ThemeProperties {name:$name, version:$version}';

  @override
  List<Object?> get props => [name, version];
}
