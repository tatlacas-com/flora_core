part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi {}

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();
}

class ItemsLoadingState extends ItemsManagerState implements ItemsBuildUi {
  const ItemsLoadingState();

  @override
  List<Object> get props => [];
}

class ItemsInitialState extends ItemsManagerState implements ItemsBuildUi {
  const ItemsInitialState();

  @override
  List<Object> get props => [];
}

abstract class LoadedState extends ItemsManagerState {
  const LoadedState({
    required this.sections,
    required this.reachedBottom,
  });
  final List<Section> sections;

  int get totalSections => sections.length;
  final bool reachedBottom;

  int totalSectionItems(int section) => sections[section].items.length;

  bool get isEmpty => sections.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool isSectionEmpty(int section) => sections[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => sections[section].items.isNotEmpty;

  Section section(int section) => sections[section];

  bool usesGrid(int section) => sections[section].usesGrid;

  dynamic sectionHeader(int section) => sections[section].sectionHeader;

  @override
  List<Object?> get props => [sections];
}

class ItemsRetrievedState extends LoadedState implements ItemsBuildUi {
  const ItemsRetrievedState({
    required List<Section> items,
    super.reachedBottom = false,
  }) : super(sections: items);
}

class ReloadingItemsState extends LoadedState implements ItemsBuildUi {
  const ReloadingItemsState({
    required List<Section> items,
    super.reachedBottom = false,
  }) : super(sections: items);
}

class ItemReplacedState extends ItemChangedState {
  const ItemReplacedState({
    required super.itemSection,
    required super.itemIndex,
    super.id,
    super.changeParams,
    required super.reachedBottom,
    required super.removedItem,
    required super.insertedItem,
    required super.sections,
  });
}

class ItemRemovedState extends ItemChangedState {
  const ItemRemovedState({
    required super.itemSection,
    required super.reachedBottom,
    super.id,
    super.changeParams,
    required super.itemIndex,
    required super.removedItem,
    required super.sections,
  });
}

class ItemInsertedState extends ItemChangedState {
  const ItemInsertedState({
    required super.itemSection,
    required super.reachedBottom,
    super.id,
    super.changeParams,
    required super.itemIndex,
    required super.insertedItem,
    required super.sections,
    this.animated = false,
  });
  final bool animated;
  @override
  List<Object?> get props => [...super.props, animated];
}

class ItemChangedState extends LoadedState {
  const ItemChangedState({
    required this.itemSection,
    required super.reachedBottom,
    required this.itemIndex,
    this.removedItem,
    this.changeParams,
    this.insertedItem,
    this.id,
    required super.sections,
  });
  final dynamic removedItem, insertedItem, changeParams;
  final int itemSection, itemIndex;
  final String? id;

  @override
  List<Object?> get props => [
        removedItem,
        insertedItem,
        itemSection,
        itemIndex,
        id,
        changeParams,
      ];
}

class ReloadFromCloudEmptyState extends ItemsManagerState {
  ReloadFromCloudEmptyState({DateTime? loadId})
      : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}

class LoadItemsFailedState extends ItemsManagerState implements ItemsBuildUi {
  LoadItemsFailedState({
    DateTime? loadId,
    required this.exceptionType,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;
  final NetworkExceptionType exceptionType;

  @override
  List<Object> get props => [loadId, exceptionType];
}

class LoadMoreItemsFailedState extends LoadedState {
  LoadMoreItemsFailedState({
    DateTime? loadId,
    required super.reachedBottom,
    required this.exceptionType,
    required super.sections,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;
  final NetworkExceptionType exceptionType;

  @override
  List<Object> get props => [loadId, exceptionType];
}

class LoadingMoreItemsState extends LoadedState {
  LoadingMoreItemsState({
    DateTime? loadId,
    required super.reachedBottom,
    required super.sections,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}

class ItemsReloadedState extends LoadedState {
  ItemsReloadedState({
    DateTime? loadId,
    required super.reachedBottom,
    required super.sections,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}
