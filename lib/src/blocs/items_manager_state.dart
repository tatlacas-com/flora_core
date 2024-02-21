part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi {}

abstract class ItemsManagerState<T extends SerializableItem> extends Equatable {
  const ItemsManagerState();
}

class ItemsLoadingState<T extends SerializableItem> extends ItemsManagerState<T>
    implements ItemsBuildUi {
  const ItemsLoadingState();

  @override
  List<Object> get props => [];
}

class ItemsInitialState<T extends SerializableItem> extends ItemsManagerState<T>
    implements ItemsBuildUi {
  const ItemsInitialState();

  @override
  List<Object> get props => [];
}

abstract class LoadedState<T extends SerializableItem>
    extends ItemsManagerState<T> {
  const LoadedState({
    required this.sections,
    required this.reachedBottom,
  });
  final List<Section<T>> sections;

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
  dynamic sectionFooter(int section) => sections[section].sectionFooter;

  @override
  List<Object?> get props => [sections];
}

class ItemsRetrievedState<T extends SerializableItem> extends LoadedState<T>
    implements ItemsBuildUi {
  const ItemsRetrievedState({
    required super.sections,
    super.reachedBottom = false,
  });
}

class ReloadingItemsState<T extends SerializableItem> extends LoadedState<T>
    implements ItemsBuildUi {
  const ReloadingItemsState({
    required super.sections,
    super.reachedBottom = false,
  });
}

class ItemReplacedState<T extends SerializableItem>
    extends ItemChangedState<T> {
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

class ItemRemovedState<T extends SerializableItem> extends ItemChangedState<T> {
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

class ItemInsertedState<T extends SerializableItem>
    extends ItemChangedState<T> {
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

class ItemChangedState<T extends SerializableItem> extends LoadedState<T> {
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

class ReloadFromCloudEmptyState<T extends SerializableItem>
    extends ItemsManagerState<T> {
  ReloadFromCloudEmptyState({DateTime? loadId})
      : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}

class LoadItemsFailedState<T extends SerializableItem>
    extends ItemsManagerState<T> implements ItemsBuildUi {
  LoadItemsFailedState({
    DateTime? loadId,
    required this.exceptionType,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;
  final NetworkExceptionType exceptionType;

  @override
  List<Object> get props => [loadId, exceptionType];
}

class LoadMoreItemsFailedState<T extends SerializableItem>
    extends LoadedState<T> {
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

class LoadingMoreItemsState<T extends SerializableItem> extends LoadedState<T> {
  LoadingMoreItemsState({
    DateTime? loadId,
    required super.reachedBottom,
    required super.sections,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}

class ItemsReloadedState<T extends SerializableItem> extends LoadedState<T> {
  ItemsReloadedState({
    DateTime? loadId,
    required super.reachedBottom,
    required super.sections,
  }) : loadId = loadId ?? DateTime.now();
  final DateTime loadId;

  @override
  List<Object> get props => [loadId];
}
