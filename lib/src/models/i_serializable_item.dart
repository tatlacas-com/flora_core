import 'package:equatable/equatable.dart';

class SerializableItem extends Equatable {
  const SerializableItem({this.id});

  factory SerializableItem.fromMap(Map<String, dynamic> map) {
    return SerializableItem(
      id: map['id'] != null ? map['id'] as String : null,
    );
  }

  final String? id;
  @override
  List<Object?> get props => [id];

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
    };
  }
}
