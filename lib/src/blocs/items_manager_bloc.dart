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
      ItemsManagerState initialState = const ItemsLoading()})
      : super(initialState) {
    on<LoadItemsRequested>(onLoadItemsRequested);
    on<ReloadItemsRequested>(onReloadItemsRequested);
    on<ReplaceItem>(onReplaceItem);
  }

  bool isReplacingItem({required int section, required int index, required dynamic item}){
    if(state is! ItemReplaced)return false;
    final _st = state as ItemReplaced;
    return _st.itemSection == section && _st.itemIndex == index && _st.insertedItem == item;
  }

  @protected
  FutureOr<void> onReplaceItem(
      ReplaceItem event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadedItemsState) {
      final state = (this.state as LoadedItemsState);
      final removedItem =
          state.section(event.section).items.removeAt(event.index);
      state.section(event.section).items.insert(event.index, event.item);
      emit(ItemReplaced(
          itemSection: event.section,
          itemIndex: event.index,
          removedItem: removedItem,
          insertedItem: event.item,
          items: state.items));
    }
  }

  @protected
  FutureOr<void> onReloadItemsRequested(
      ReloadItemsRequested event, Emitter<ItemsManagerState> emit) async {
    try {
      emit(ItemsLoading());
      if (event.fromCloud) {
        var _items = await repo.loadItemsFromCloud(event.context);
        if (_items.isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          emit(ItemsLoaded(items: _items));
          return;
        }
        emit(ReloadFromCloudEmpty());
        _items = await repo.loadItemsFromLocalStorage(event.context);
        emit(ItemsLoaded(items: _items));
      } else {
        var _items = await repo.loadItemsFromLocalStorage(event.context);
        emit(ItemsLoaded(items: _items));
      }
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailed());
    }
  }

  @protected
  FutureOr<void> onLoadItemsRequested(
      LoadItemsRequested event, Emitter<ItemsManagerState> emit) async {
    try {
      var _items = await repo.loadItemsFromLocalStorage(event.context);
      if (_items.isNotEmpty) {
        emit(ItemsLoaded(items: _items));
        return;
      }
      _items = await repo.loadItemsFromCloud(event.context);
      emit(ItemsLoaded(items: _items));
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailed());
    }
  }
}
