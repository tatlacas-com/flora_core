// ignore_for_file: unnecessary_this

part of 'items_manager_bloc.dart';

abstract class ItemsManagerEvent extends Equatable {
  ItemsManagerEvent({DateTime? requestId})
      : this.requestId = requestId ?? DateTime.now();
  final DateTime requestId;

  @override
  List<Object?> get props => [requestId];
}

final class LoadItemsEvent extends ItemsManagerEvent {
  LoadItemsEvent({required this.onTapUrl, required this.theme});
  final Function(String url) onTapUrl;
  final ThemeData theme;
}

final class _LoaderEvent extends ItemsManagerEvent {
  _LoaderEvent(this.event);
  final ItemsManagerEvent event;
}

abstract class ChangeItemEvent extends ItemsManagerEvent {
  ChangeItemEvent({
    required this.item,
    required this.section,
    required this.index,
  });
  final dynamic item;
  final int section;
  final int index;

  @override
  List<Object?> get props => [item, section, index];
}

final class ReplaceItemEvent extends ChangeItemEvent {
  ReplaceItemEvent({
    required super.item,
    required super.section,
    required super.index,
  });
}

final class RemoveItemEvent extends ChangeItemEvent {
  RemoveItemEvent({
    required super.item,
    required super.section,
    required super.index,
  });
}

final class InsertItemEvent extends ChangeItemEvent {
  InsertItemEvent({
    required super.item,
    required super.section,
    required super.index,
  });
}

final class ReloadItemsEvent extends ItemsManagerEvent {
  ReloadItemsEvent({
    this.fromCloud = true,
    this.loadFromLocalIfCloudEmpty = true,
    required this.onTapUrl,
    required this.theme,
    super.requestId,
  });
  final bool fromCloud;
  final bool loadFromLocalIfCloudEmpty;
  final Function(String url) onTapUrl;
  final ThemeData theme;

  @override
  List<Object?> get props => [fromCloud, loadFromLocalIfCloudEmpty, requestId];
}

final class LoadMoreItemsEvent extends ItemsManagerEvent {
  LoadMoreItemsEvent({
    super.requestId,
    required this.onTapUrl,
    required this.theme,
  });
  final Function(String url) onTapUrl;
  final ThemeData theme;
}

final class EmitRetrievedEvent extends ItemsManagerEvent {}
