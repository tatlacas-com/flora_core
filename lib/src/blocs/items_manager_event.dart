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

abstract class ChangeItem extends ItemsManagerEvent {
  final BuildContext context;
  final dynamic item;
  final int section;
  final int index;

  ChangeItem(
      {required this.context,
      required this.item,
      required this.section,
      required this.index});

  @override
  List<Object?> get props => [item, section, index];
}

class ReplaceItem extends ChangeItem {
  ReplaceItem({
    required BuildContext context,
    required dynamic item,
    required int section,
    required int index,
  }) : super(context: context, item: item, section: section, index: index);
}

class RemoveItem extends ChangeItem {
  RemoveItem({
    required BuildContext context,
    required dynamic item,
    required int section,
    required int index,
  }) : super(context: context, item: item, section: section, index: index);
}

class InsertItem extends ChangeItem {
  InsertItem({
    required BuildContext context,
    required dynamic item,
    required int section,
    required int index,
  }) : super(context: context, item: item, section: section, index: index);
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
