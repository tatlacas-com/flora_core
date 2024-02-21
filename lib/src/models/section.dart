import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/i_serializable_item.dart';

class LoadItemsResult<T> {
  LoadItemsResult({required this.items, required this.count});
  factory LoadItemsResult.empty() => LoadItemsResult(items: [], count: 0);

  final List<T> items;

  /// count of items returned by the server
  final int count;
}

class Section<T extends PersistableMixin> extends Equatable {
  const Section({
    this.sectionHeader,
    this.sectionFooter,
    this.emptyEntity = const SizedBox(),
    this.usesGrid = false,
    this.horizontalScroll = false,
    this.items = const [],
  });
  final List<T> items;
  final dynamic sectionHeader;
  final dynamic sectionFooter;
  final bool usesGrid;
  final bool horizontalScroll;
  bool get isEmpty => items.isEmpty;
  final dynamic emptyEntity;

  bool get isNotEmpty => !isEmpty;
  int totalItems() {
    return items.length;
  }

  @override
  List<Object?> get props => [
        items,
        sectionHeader,
        sectionFooter,
        usesGrid,
        horizontalScroll,
      ];

  Section<T> copyWith({
    List<T>? items,
    dynamic sectionHeader,
    bool? usesGrid,
    bool? horizontalScroll,
    dynamic emptyEntity,
  }) {
    return Section(
      items: items ?? this.items,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      usesGrid: usesGrid ?? this.usesGrid,
      horizontalScroll: horizontalScroll ?? this.horizontalScroll,
      emptyEntity: emptyEntity ?? this.emptyEntity,
    );
  }
}
