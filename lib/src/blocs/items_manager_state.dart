part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi {}

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();
}

class ItemsLoadingState extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'ItemsLoading';

  const ItemsLoadingState({DateTime? loadId});

  @override
  List<Object> get props => [];
}

abstract class LoadedState extends ItemsManagerState {
  final List<Section> sections;

  int get totalSections => sections.length;

  int totalSectionItems(int section) => sections[section].items.length;

  bool get isEmpty => sections.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool isSectionEmpty(int section) => sections[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => sections[section].items.isNotEmpty;

  Section section(int section) => sections[section];

  bool usesGrid(int section) => sections[section].usesGrid;

  dynamic sectionHeader(int section) => sections[section].sectionHeader;

  LoadedState({required this.sections});

  @override
  List<Object?> get props => [sections];
}

class ItemsRetrievedState extends LoadedState implements ItemsBuildUi {
  ItemsRetrievedState({required List<Section> items}) : super(sections: items);

  @override
  String toString() => 'ItemsLoaded';
}

class ItemReplacedState extends ItemChangedState implements ItemsBuildUi {
  ItemReplacedState(
      {required int itemSection,
      required int itemIndex,
      required dynamic removedItem,
      required dynamic insertedItem,
      required List<Section> items})
      : super(
          itemIndex: itemIndex,
          itemSection: itemSection,
          items: items,
          removedItem: removedItem,
          insertedItem: insertedItem,
        );
}

class ItemRemovedState extends ItemChangedState  {
  ItemRemovedState(
      {required int itemSection,
      required int itemIndex,
      required dynamic removedItem,
      required List<Section> items})
      : super(
          itemIndex: itemIndex,
          itemSection: itemSection,
          items: items,
          removedItem: removedItem,
        );
}

class ItemInsertedState extends ItemChangedState {
  ItemInsertedState(
      {required int itemSection,
      required int itemIndex,
      required dynamic insertedItem,
      required List<Section> items})
      : super(
          itemIndex: itemIndex,
          itemSection: itemSection,
          items: items,
          insertedItem: insertedItem,
        );
}

class ItemChangedState extends LoadedState {
  final dynamic removedItem, insertedItem;
  final int itemSection, itemIndex;

  ItemChangedState(
      {required this.itemSection,
      required this.itemIndex,
      this.removedItem,
      this.insertedItem,
      required List<Section> items})
      : super(sections: items);

  @override
  List<Object?> get props => [removedItem, insertedItem, itemSection, itemIndex];
}

class ReloadFromCloudEmptyState extends ItemsManagerState {
  @override
  String toString() => 'ReloadFromCloudEmpty';
  final DateTime loadId;

  ReloadFromCloudEmptyState({DateTime? loadId})
      : this.loadId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [loadId];
}

class LoadItemsFailedState extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'LoadItemsFailed';
  final DateTime loadId;

  LoadItemsFailedState({DateTime? loadId}) : this.loadId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [loadId];
}
