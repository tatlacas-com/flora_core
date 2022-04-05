import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode, protected;
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/section.dart';

import '../items_repo.dart';

part 'items_manager_event.dart';

part 'items_manager_state.dart';

abstract class ItemsManagerBloc<TRepo extends ItemsRepo>
    extends Bloc<ItemsManagerEvent, ItemsManagerState> {
  final TRepo repo;

  ItemsManagerBloc(
      {required this.repo,
      ItemsManagerState initialState = const ItemsLoadingState()})
      : super(initialState) {
    on<LoadItemsEvent>(onLoadItemsRequested);
    on<ReloadItemsEvent>(onReloadItemsRequested);
    on<ReplaceItemEvent>(onReplaceItem);
    on<InsertItemEvent>(onInsertItem);
    on<RemoveItemEvent>(onRemoveItem);
  }

  bool isReplacingItem(
      {required int section, required int index, required dynamic item}) {
    if (state is! ItemReplacedState) return false;
    final _st = state as ItemReplacedState;
    return _st.itemSection == section &&
        _st.itemIndex == index &&
        _st.insertedItem == item;
  }

  @protected
  FutureOr<void> onReplaceItem(
      ReplaceItemEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadedState) {
      final state = (this.state as LoadedState);
      final removedItem =
          state.section(event.section).items.removeAt(event.index);
      state.section(event.section).items.insert(event.index, event.item);
      emit(ItemReplacedState(
          itemSection: event.section,
          itemIndex: event.index,
          removedItem: removedItem,
          insertedItem: event.item,
          sections: state.sections));
    }
  }

  @protected
  FutureOr<void> onInsertItem(
      InsertItemEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadedState) {
      final state = (this.state as LoadedState);
      state.section(event.section).items.insert(event.index, event.item);

      emit(ItemInsertedState(
          itemSection: event.section,
          itemIndex: event.index,
          insertedItem: event.item,
          sections: state.sections));
    }
  }

  @protected
  FutureOr<void> onRemoveItem(
      RemoveItemEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadedState) {
      final state = (this.state as LoadedState);
      final removedItem =
          state.section(event.section).items.removeAt(event.index);
      emit(ItemRemovedState(
          itemSection: event.section,
          itemIndex: event.index,
          removedItem: removedItem,
          sections: state.sections));
      if (state.section(event.section).isEmpty) {
        await Future.delayed(const Duration(milliseconds: 500));
        state.sections.removeAt(event.section);
        emit(ItemsRetrievedState(items: state.sections));
      }
    }
  }

  @protected
  FutureOr<void> onReloadItemsRequested(
      ReloadItemsEvent event, Emitter<ItemsManagerState> emit) async {
    try {
      emit(const ItemsLoadingState());
      if (event.fromCloud) {
        var _items = await repo.loadItemsFromCloud(event.context);
        if (_items.isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          await emitItemsRetrieved(emit, _items);
          return;
        }
        emit(ReloadFromCloudEmptyState());
        _items = await repo.loadItemsFromLocalStorage(event.context);
        await emitItemsRetrieved(emit, _items);
      } else {
        var _items = await repo.loadItemsFromLocalStorage(event.context);
        await emitItemsRetrieved(emit, _items);
      }
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailedState());
    }
  }

  FutureOr<void> emitItemsRetrieved(Emitter<ItemsManagerState> emit, List<Section> _items) async {
     emit(ItemsRetrievedState(items: _items));
  }

  @protected
  FutureOr<void> onLoadItemsRequested(
      LoadItemsEvent event, Emitter<ItemsManagerState> emit) async {
    try {
      var _items = await repo.loadItemsFromLocalStorage(event.context);
      if (_items.isNotEmpty) {
        await emitItemsRetrieved(emit, _items);
        return;
      }
      _items = await repo.loadItemsFromCloud(event.context);
      await emitItemsRetrieved(emit, _items);
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailedState());
    }
  }
}
