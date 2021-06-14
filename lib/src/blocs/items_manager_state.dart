part of 'items_manager_bloc.dart';

abstract class ItemsManagerState extends Equatable {
  const ItemsManagerState();

  @override
  List<Object> get props => [];
}

class ItemsLoading extends ItemsManagerState {
  @override
  String toString() => 'ItemsLoading';
}
class ItemsLoaded extends ItemsManagerState {
  @override
  String toString() => 'ItemsLoaded';
}

class ReloadFromCloudEmpty extends ItemsManagerState{
  @override
  String toString() => 'ReloadFromCloudEmpty';
}

class LoadItemsFailed extends ItemsManagerState {
  @override
  String toString() => 'LoadItemsFailed';
}
