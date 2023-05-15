import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Section extends Equatable {

  const Section({
    this.sectionHeader,
    this.emptyEntity = const SizedBox(),
    this.usesGrid = false,
    this.horizontalScroll = false,
    this.items = const [],
    this.horizontalScrollHeight = 100,
  });
  final List<dynamic> items;
  final dynamic sectionHeader;
  final bool usesGrid;
  final bool horizontalScroll;
  final double horizontalScrollHeight;
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
        usesGrid,
        horizontalScroll,
        horizontalScrollHeight,
      ];

  Section copyWith({
    List<dynamic>? items,
    dynamic sectionHeader,
    bool? usesGrid,
    bool? horizontalScroll,
    double? horizontalScrollHeight,
    dynamic emptyEntity,
  }) {
    return Section(
      items: items ?? this.items,
      sectionHeader: sectionHeader ?? this.sectionHeader,
      usesGrid: usesGrid ?? this.usesGrid,
      horizontalScroll: horizontalScroll ?? this.horizontalScroll,
      horizontalScrollHeight:
          horizontalScrollHeight ?? this.horizontalScrollHeight,
      emptyEntity: emptyEntity ?? this.emptyEntity,
    );
  }
}
