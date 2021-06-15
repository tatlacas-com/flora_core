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
  @override
  String toString() => 'ItemsLoaded';
}

class ReloadFromCloudEmpty extends ItemsManagerState{
  @override
  String toString() => 'ReloadFromCloudEmpty';
}

class LoadItemsFailed extends ItemsManagerState implements ItemsBuildUi {
  @override
  String toString() => 'LoadItemsFailed';
}
