import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode, protected;
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/exceptions.dart';
import 'package:tatlacas_flutter_core/src/models/section.dart';

import '../items_repo.dart';

part 'items_manager_event.dart';

part 'items_manager_state.dart';

abstract class ItemsManagerBloc<TRepo extends ItemsRepo>
    extends Bloc<ItemsManagerEvent, ItemsManagerState> {
  final TRepo repo;
  bool _loading = false;

  bool get loading => _loading;

  ItemsManagerBloc(
      {required this.repo,
      ItemsManagerState initialState = const ItemsInitialState()})
      : super(initialState) {
    on<LoadItemsEvent>(onLoadItemsRequested);
    on<ReloadItemsEvent>(onReloadItemsRequested);
    on<ReplaceItemEvent>(onReplaceItem);
    on<InsertItemEvent>(onInsertItem);
    on<RemoveItemEvent>(onRemoveItem);
    on<LoadMoreItemsEvent>(onLoadMoreItemsEvent);
    on<EmitRetrievedEvent>(onEmitRetrievedEvent);
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
  FutureOr<void> onEmitRetrievedEvent(
      EmitRetrievedEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is! LoadedState) return;
    final loadedState = state as LoadedState;
    emit(ItemsRetrievedState(items: loadedState.sections));
  }

  @protected
  FutureOr<void> onReplaceItem(
      ReplaceItemEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is! LoadedState) return;
    final loadedState = state as LoadedState;
    final removedItem =
        loadedState.section(event.section).items.removeAt(event.index);
    loadedState.section(event.section).items.insert(event.index, event.item);
    emit(ItemReplacedState(
        reachedBottom: loadedState.reachedBottom,
        itemSection: event.section,
        itemIndex: event.index,
        removedItem: removedItem,
        insertedItem: event.item,
        sections: loadedState.sections));
  }

  @protected
  FutureOr<void> onInsertItem(
      InsertItemEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadedState) {
      final state = (this.state as LoadedState);
      state.section(event.section).items.insert(event.index, event.item);

      emit(
        ItemInsertedState(
            reachedBottom: state.reachedBottom,
            itemSection: event.section,
            itemIndex: event.index,
            insertedItem: event.item,
            sections: state.sections),
      );
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
        reachedBottom: state.reachedBottom,
        itemIndex: event.index,
        removedItem: removedItem,
        sections: state.sections,
      ));
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
    if (_loading) return;
    _loading = true;
    if (state is LoadedState) {
      var loadedState = state as LoadedState;
      for (var x = loadedState.sections.length - 1; x >= 0; x--) {
        var section = loadedState.sections[x];
        for (var i = section.items.length - 1; i >= 0; i--) {
          var removed = section.items.removeAt(i);
          emit(
            ItemRemovedState(
              itemSection: x,
              reachedBottom: loadedState.reachedBottom,
              itemIndex: i,
              removedItem: removed,
              sections: loadedState.sections,
            ),
          );
        }
      }
    }
    try {
      emit(const ItemsLoadingState());
      if (event.fromCloud) {
        var loadedItems = await repo.loadItemsFromCloud();
        if (loadedItems.isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          _loading = false;
          await emitItemsReloadRetrieved(emit, loadedItems);
          return;
        }
        emit(ReloadFromCloudEmptyState());
        loadedItems = await repo.loadItemsFromLocalStorage();
        _loading = false;
        await emitItemsReloadRetrieved(emit, loadedItems);
      } else {
        var loadedItems = await repo.loadItemsFromLocalStorage();
        _loading = false;
        await emitItemsReloadRetrieved(emit, loadedItems);
      }
    } catch (e) {
      if (kDebugMode) print('Error: $runtimeType onReloadItemsRequested: $e');
      _loading = false;
      await onLoadItemsException(emit, e);
    }
  }

  FutureOr<void> emitItemsRetrieved(
      Emitter<ItemsManagerState> emit, List<Section> items) async {
    emit(ItemsRetrievedState(items: items));
  }

  FutureOr<void> emitItemsReloadRetrieved(
      Emitter<ItemsManagerState> emit, List<Section> items) async {
    emit( ItemsRetrievedState(items: items));
   /* 
    final totalSections = items.length - 1;
    List<Section> sections = [];
   for (var x = 0; x < items.length; x++) {
      var section = items[x];
      sections.add(section.copyWith(items: []));
      for (var i = 0; i < section.items.length; i++) {
        var isLastItem = x == totalSections && i == section.items.length - 1;
        sections[x].items.add(section.items[i]);
        emit(
          ItemInsertedState(
              itemSection: x,
              reachedBottom: !isLastItem,
              itemIndex: i,
              insertedItem: section.items[i],
              sections: sections),
        );
      }
    }*/
  }

  @protected
  FutureOr<void> onLoadItemsRequested(
      LoadItemsEvent event, Emitter<ItemsManagerState> emit) async {
    if (_loading) return;
    _loading = true;

    if (state is LoadingMoreItemsState) return;
    emit(const ItemsLoadingState());
    try {
      var loadedItems = await repo.loadItemsFromLocalStorage();
      if (loadedItems.isNotEmpty) {
        _loading = false;
        await emitItemsRetrieved(emit, loadedItems);
        return;
      }
      loadedItems = await repo.loadItemsFromCloud();
      _loading = false;
      await emitItemsRetrieved(emit, loadedItems);
    } catch (e) {
      if (kDebugMode) print('Error: $runtimeType onLoadItemsRequested: $e');
      _loading = false;
      await onLoadItemsException(emit, e);
    }
  }

  Future onLoadItemsException(
      Emitter<ItemsManagerState> emit, dynamic e) async {
    emit(LoadItemsFailedState(
        exceptionType: e is NetworkException
            ? e.exceptionType
            : NetworkExceptionType.unknown));
  }

  dynamic loadingMoreItem(int section) => null;

  dynamic get bottomSpacer => null;

  int get pageSize => 20;

  Future<List<dynamic>> prepareLoadMoreItems(
      LoadMoreItemsEvent event, Emitter<ItemsManagerState> emit) async {
    var loadedState = state as LoadedState;
    var lastSection = loadedState.sections.length - 1;
    var lastItemIndex = loadedState.sections[lastSection].items.length;
    var insertedItem = loadingMoreItem(lastSection);
    if (insertedItem != null &&
        loadedState.sections[lastSection].items.isNotEmpty &&
        loadedState.sections[lastSection].items.last != insertedItem) {
      debugPrint('INSERT LOADING CELL');
      loadedState.sections[lastSection].items.add(insertedItem);
      emit(
        ItemInsertedState(
          itemSection: lastSection,
          reachedBottom: loadedState.reachedBottom,
          itemIndex: lastItemIndex,
          insertedItem: insertedItem,
          sections: loadedState.sections,
        ),
      );
    }
    return await loadMoreItems(
        event, emit, loadedState.sections[lastSection].items.length);
  }

  Future<List<dynamic>> loadMoreItems(LoadMoreItemsEvent event,
          Emitter<ItemsManagerState> emit, int lastItemIndex) async =>
      [];

  bool hasReachedBottom(int section, List<dynamic> items) =>
      items.length < pageSize;

  bool removeLoadingIfBottomReached(int section) => true;

  FutureOr<void> emitMoreItemsRetrieved(
      Emitter<ItemsManagerState> emit, List<dynamic> _items) async {
    var loadedState = state as LoadedState;
    var lastSection = loadedState.sections.length - 1;
    lastSection = lastSection < 0 ? 0 : lastSection;
    var reachedBottom = hasReachedBottom(lastSection, _items);
    if (loadedState.sections[lastSection].items.isNotEmpty &&
        loadedState.sections[lastSection].items.last ==
            loadingMoreItem(lastSection)) {
      try {
        var removed = loadedState.sections[lastSection].items.removeLast();
        if (loadingMoreItem(lastSection) != null &&
            removeLoadingIfBottomReached(lastSection)) {
          emit(
            ItemRemovedState(
              itemSection: lastSection,
              reachedBottom: reachedBottom,
              itemIndex: loadedState.sections[lastSection].items.length,
              removedItem: removed,
              sections: loadedState.sections,
            ),
          );
        }
      } catch (e) {
        if (kDebugMode) print('Error: $runtimeType emitMoreItemsRetrieved: $e');
        await onLoadItemsException(emit, e);
      }
    }

    var indx = 0;
    for (var item in _items) {
      loadedState.sections[lastSection].items.add(item);
      emit(
        ItemInsertedState(
          reachedBottom: reachedBottom,
          itemSection: lastSection,
          itemIndex: indx++,
          insertedItem: item,
          sections: loadedState.sections,
        ),
      );
    }
    if (reachedBottom) {
      try {
        _insertBottomSpacer(
          loadedState,
          emit,
        );
      } catch (e) {
        if (kDebugMode) print('Error: $runtimeType insertBottomSpacer: $e');
        await onLoadItemsException(emit, e);
      }
    }
  }

  void _insertBottomSpacer(
      LoadedState loadedState, Emitter<ItemsManagerState> emit) {
    var spacer = bottomSpacer;
    if (spacer != null) {
      var lastSection = loadedState.sections.length - 1;
      if (lastSection < 0 ||
          loadedState.sections[lastSection].items.isEmpty ||
          loadedState.sections[lastSection].items.last == spacer) return;
      loadedState.sections[lastSection].items.add(spacer);
      emit(
        ItemInsertedState(
          itemSection: lastSection,
          reachedBottom: loadedState.reachedBottom,
          itemIndex: loadedState.sections[lastSection].items.length - 1,
          insertedItem: spacer,
          sections: loadedState.sections,
        ),
      );
    }
  }

  bool _loadingMore = false;

  @protected
  FutureOr<void> onLoadMoreItemsEvent(
      LoadMoreItemsEvent event, Emitter<ItemsManagerState> emit) async {
    if (_loadingMore) return;
    if (state is! LoadedState) return;
    var loadedState = state as LoadedState;
    if (loadedState.reachedBottom) return;
    _loadingMore = true;
    try {
      emit(
        LoadingMoreItemsState(
          sections: loadedState.sections,
          reachedBottom: false,
        ),
      );
      var items = await prepareLoadMoreItems(event, emit);
      await emitMoreItemsRetrieved(emit, items);
    } catch (e) {
      if (kDebugMode) print('Error: $runtimeType onLoadMoreItemsEvent  $e');
      await onLoadMoreItemsException(emit, loadedState, e);
    }
    _loadingMore = false;
  }

  Future onLoadMoreItemsException(Emitter<ItemsManagerState> emit,
      LoadedState loadedState, dynamic e) async {
    emit(
      LoadMoreItemsFailedState(
        reachedBottom: false,
        sections: loadedState.sections,
        exceptionType: e is NetworkException
            ? e.exceptionType
            : NetworkExceptionType.unknown,
      ),
    );
  }
}
