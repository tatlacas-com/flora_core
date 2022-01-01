import 'package:equatable/equatable.dart';

class Section extends Equatable {
  final List<dynamic> items;
  final dynamic sectionHeader;
  final bool usesGrid;
  final bool horizontalScroll;
  final double horizontalScrollHeight;
  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => !isEmpty;
  int totalItems() {
    return items.length;
  }

  Section({
    this.sectionHeader,
    this.usesGrid = false,
    this.horizontalScroll = false,
    this.items = const [],
    this.horizontalScrollHeight = 100,
  });

  @override
  List<Object?> get props => [
        items,
        sectionHeader,
        usesGrid,
        horizontalScroll,
        horizontalScrollHeight,
      ];
}
