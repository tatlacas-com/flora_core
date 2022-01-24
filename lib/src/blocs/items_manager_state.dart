part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi {}

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();
}

class ItemsLoading extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'ItemsLoading';

  const ItemsLoading({DateTime? loadId}) ;

  @override
  List<Object> get props => [];
}

abstract class LoadedItemsState extends ItemsManagerState {
  final List<Section> items;


  int get totalSections => items.length;

  int totalSectionItems(int section) => items[section].items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool isSectionEmpty(int section) => items[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => items[section].items.isNotEmpty;

  Section section(int section) => items[section];

  bool usesGrid(int section) => items[section].usesGrid;

  dynamic sectionHeader(int section) => items[section].sectionHeader;

  LoadedItemsState({required this.items});

  @override
  List<Object> get props => [items];
}

class ItemsLoaded extends LoadedItemsState implements ItemsBuildUi {

  ItemsLoaded({required List<Section> items}) : super(items: items);

  @override
  String toString() => 'ItemsLoaded';
}

class ReloadFromCloudEmpty extends ItemsManagerState {
  @override
  String toString() => 'ReloadFromCloudEmpty';
  final DateTime loadId;

  ReloadFromCloudEmpty({DateTime? loadId}) : this.loadId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [loadId];
}

class LoadItemsFailed extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'LoadItemsFailed';
  final DateTime loadId;

  LoadItemsFailed({DateTime? loadId}) : this.loadId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [loadId];
}
