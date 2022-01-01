part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi {}

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();
}

class ItemsLoading extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'ItemsLoading';
  final DateTime requestId;

  ItemsLoading({DateTime? loadId}) : this.requestId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [requestId];
}

class ItemsLoaded extends ItemsManagerState implements ItemsBuildUi {
  final DateTime loadId;

  ItemsLoaded({DateTime? loadId}) : this.loadId = loadId ?? DateTime.now();

  @override
  List<Object> get props => [loadId];

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
