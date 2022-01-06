part of 'items_manager_bloc.dart';

abstract class ItemsManagerEvent extends Equatable {
  final DateTime requestId;

  ItemsManagerEvent({DateTime? requestId})
      : this.requestId = requestId ?? DateTime.now();

  @override
  List<Object?> get props => [requestId];
}

class LoadItemsRequested extends ItemsManagerEvent {
  final BuildContext context;

  LoadItemsRequested({required this.context, DateTime? requestId});

  @override
  String toString() => 'LoadItemsRequested';
}

class ReplaceItem extends ItemsManagerEvent {
  final BuildContext context;
  final dynamic item;
  final int section;
  final int index;

  ReplaceItem(
      {required this.context,
      required this.item,
      required this.section,
      required this.index});

  @override
  List<Object?> get props => [item, section, index];

  @override
  String toString() => 'LoadItemsRequested';
}

class ReloadItemsRequested extends ItemsManagerEvent {
  final bool fromCloud;
  final bool loadFromLocalIfCloudEmpty;
  final BuildContext context;

  ReloadItemsRequested(
      {required this.context,
      this.fromCloud = true,
      this.loadFromLocalIfCloudEmpty = true,
      DateTime? requestId})
      : super(requestId: requestId);

  @override
  String toString() => 'ReloadItemsRequested';

  @override
  List<Object?> get props => [fromCloud, loadFromLocalIfCloudEmpty, requestId];
}

class LoadItemsFromCloudRequested extends ItemsManagerEvent {
  LoadItemsFromCloudRequested({DateTime? requestId})
      : super(requestId: requestId);

  @override
  String toString() => 'LoadItemsFromCloudRequested';
}
