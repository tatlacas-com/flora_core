import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ResponseItems<T> {
  ResponseItems(
      {required this.items, required this.count, this.reloadFromCloud = false});
  factory ResponseItems.empty() => ResponseItems(items: [], count: 0);

  final List<T> items;

  /// count of items returned by the server. Is used to compare pageSize with response to determine if all items have been retrieved.
  /// If count < pageSize then it is assumed that all items have been retrieved
  final int count;
  final bool reloadFromCloud;
}

enum ItemPresentationStyle {
  list,
  grid;

  bool get isGrid => this == grid;
  bool get isList => this == list;
}

class Section extends Equatable {
  const Section({
    this.sectionHeader,
    this.sectionFooter,
    this.emptyEntity = const SizedBox(),
    this.presentationStyle = ItemPresentationStyle.list,
    this.horizontalScroll = false,
    this.items = const [],
  });
  final List<dynamic> items;
  final dynamic sectionHeader;
  final dynamic sectionFooter;
  final ItemPresentationStyle presentationStyle;
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
        presentationStyle,
        horizontalScroll,
      ];

  Section copyWith({
    List<dynamic>? items,
    dynamic sectionHeader,
    ItemPresentationStyle? presentationStyle,
    bool? horizontalScroll,
    dynamic emptyEntity,
  }) {
    return Section(
      items: items ?? this.items,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      presentationStyle: presentationStyle ?? this.presentationStyle,
      horizontalScroll: horizontalScroll ?? this.horizontalScroll,
      emptyEntity: emptyEntity ?? this.emptyEntity,
    );
  }
}
