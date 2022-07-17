part of 'items_manager_bloc.dart';

abstract class ItemsManagerEvent extends Equatable {
  final DateTime requestId;

  ItemsManagerEvent({DateTime? requestId})
      : this.requestId = requestId ?? DateTime.now();

  @override
  List<Object?> get props => [requestId];
}

class LoadItemsEvent extends ItemsManagerEvent {
  LoadItemsEvent({DateTime? requestId});
}

abstract class ChangeItemEvent extends ItemsManagerEvent {
  final dynamic item;
  final int section;
  final int index;

  ChangeItemEvent({
    required this.item,
    required this.section,
    required this.index,
  });

  @override
  List<Object?> get props => [item, section, index];
}

class ReplaceItemEvent extends ChangeItemEvent {
  ReplaceItemEvent({
    required dynamic item,
    required int section,
    required int index,
  }) : super(
          item: item,
          section: section,
          index: index,
        );
}

class RemoveItemEvent extends ChangeItemEvent {
  RemoveItemEvent({
    required dynamic item,
    required int section,
    required int index,
  }) : super(
          item: item,
          section: section,
          index: index,
        );
}

class InsertItemEvent extends ChangeItemEvent {
  InsertItemEvent({
    required dynamic item,
    required int section,
    required int index,
  }) : super(
          item: item,
          section: section,
          index: index,
        );
}

class ReloadItemsEvent extends ItemsManagerEvent {
  final bool fromCloud;
  final bool loadFromLocalIfCloudEmpty;

  ReloadItemsEvent({
    this.fromCloud = true,
    this.loadFromLocalIfCloudEmpty = true,
    DateTime? requestId,
  }) : super(requestId: requestId);

  @override
  List<Object?> get props => [fromCloud, loadFromLocalIfCloudEmpty, requestId];
}

class LoadMoreItemsEvent extends ItemsManagerEvent {
  LoadMoreItemsEvent({
    DateTime? requestId,
  }) : super(requestId: requestId);
}

class EmitRetrievedEvent extends ItemsManagerEvent {}
