part of 'items_manager_bloc.dart';

abstract class ItemsManagerEvent extends Equatable {
  const ItemsManagerEvent();

  @override
  List<Object?> get props => [];
}

class LoadItemsRequested extends ItemsManagerEvent {

  const LoadItemsRequested();

  @override
  String toString() => 'LoadItemsRequested';

}

class ReloadItemsRequested extends ItemsManagerEvent{
  final bool fromCloud;
  final bool loadFromLocalIfCloudEmpty;
const ReloadItemsRequested({this.fromCloud = true,this.loadFromLocalIfCloudEmpty = true});
  @override
  String toString() => 'ReloadItemsRequested';
}

class LoadItemsFromCloudRequested extends ItemsManagerEvent {
  const LoadItemsFromCloudRequested();

  @override
  String toString() => 'LoadItemsFromCloudRequested';
}
