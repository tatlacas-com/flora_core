part of 'items_manager_bloc.dart';

abstract class ItemsBuildUi{

}

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();

  @override
  List<Object> get props => [];
}

class ItemsLoading extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'ItemsLoading';
}
class ItemsLoaded extends ItemsManagerState implements ItemsBuildUi {
  final DateTime loadId;

  ItemsLoaded({DateTime? loadId}):this.loadId = loadId ?? DateTime.now();
  @override
  String toString() => 'ItemsLoaded';

  @override
  List<Object> get props => [loadId];
}

class ReloadFromCloudEmpty extends ItemsManagerState{
  @override
  String toString() => 'ReloadFromCloudEmpty';
}

class LoadItemsFailed extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'LoadItemsFailed';
}
