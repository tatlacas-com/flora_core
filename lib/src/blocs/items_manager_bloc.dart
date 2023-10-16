import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/network_exception_type.dart';
import 'package:tatlacas_flutter_core/src/models/section.dart';
import 'package:tatlacas_flutter_core/src/widgets/items_list.dart';

import '../items_repo.dart';

part 'items_manager_event.dart';

part 'items_manager_state.dart';

///{@template itemsManagerBloc}
/// A base class to facilitate the retrieval and processing of objects that will be shown on a [ItemsListState]
///
/// ```dart
/// class ListBloc extends ItemsManagerBloc<ListRepo> {
///   ListBloc({required ListRepo repo}) : super(repo: repo);
/// }
///
/// class ListRepo extends ItemsRepo {
///   @override
///   Future<List<Section>> loadItemsFromLocalStorage() async {
///     return [
///       Section(items: ['1', '2', '3'])
///     ];
///   }
/// }
///
/// class ListScreen extends ItemsListState<ListBloc> {
///   @override
///   Widget buildListItem(
///       {required BuildContext context,
///         required int section,
///         required int index,
///         required item,
///         Animation<double>? animation,
///         bool isReplace = false,
///         bool isRemoved = false}) {
///     if(item is String){
///       return Text('Item number $item');
///     }
///     return super.buildListItem(
///       context: context,
///       section: section,
///       index: index,
///       item: item,
///       animation: animation,
///       isReplace: isReplace,
///       isRemoved: isRemoved,
///     );
///   }
/// }
///
/// ```
/// {@endtemplate}
abstract class ItemsManagerBloc<TRepo extends ItemsRepo>
    extends Bloc<ItemsManagerEvent, ItemsManagerState> {
  ItemsManagerBloc(
      {this.repo, ItemsManagerState initialState = const ItemsInitialState()})
      : super(initialState) {
    on<LoadItemsEvent>(
      (event, emit) => add(_LoaderEvent(event)),
      transformer: droppable(),
    );
    on<ReloadItemsEvent>(
      (event, emit) => add(_LoaderEvent(event)),
      transformer: droppable(),
    );
    on<ReplaceItemEvent>(onReplaceItem);
    on<InsertItemEvent>(onInsertItem);
    on<RemoveItemEvent>(onRemoveItem);
    on<LoadMoreItemsEvent>(
      onLoadMoreItemsEvent,
      transformer: droppable(),
    );
    on<EmitRetrievedEvent>(onEmitRetrievedEvent);
    on<_LoaderEvent>(
      _onLoaderEvent,
      transformer: droppable(),
    );
  }
  final TRepo? repo;

  int get itemsCount {
    final currState = state;
    if (currState is LoadedState) {
      return currState.sections.fold<int>(
          0, (previousValue, element) => element.items.length + previousValue);
    }
    return 0;
  }

  bool isReplacingItem(
      {required int section, required int index, required dynamic item}) {
    if (state is! ItemReplacedState) return false;
    final st = state as ItemReplacedState;
    return st.itemSection == section &&
        st.itemIndex == index &&
        st.insertedItem == item;
  }

  FutureOr<void> _onLoaderEvent(
      _LoaderEvent event, Emitter<ItemsManagerState> emit) async {
    final loadEvent = event.event;
    await switch (loadEvent) {
      LoadItemsEvent() => onLoadItemsRequested(loadEvent, emit),
      ReloadItemsEvent() => onReloadItemsRequested(loadEvent, emit),
      _ => Future.value(),
    };
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
          sections: state.sections,
          animated: true,
        ),
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
    try {
      final st = state;
      if (st is LoadedState) {
        emit(
          ReloadingItemsState(
            items: st.sections,
            reachedBottom: st.reachedBottom,
          ),
        );
      } else {
        emit(const ItemsLoadingState());
      }
      if (event.fromCloud) {
        var loadedItems = await loadItemsFromCloud(emit);
        if (loadedItems.isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          await emitItemsReloadRetrieved(emit, loadedItems);
          return;
        }
        emit(ReloadFromCloudEmptyState());
        loadedItems = await loadItemsFromLocalStorage(emit);
        await emitItemsReloadRetrieved(emit, loadedItems);
      } else {
        var loadedItems = await loadItemsFromLocalStorage(emit);
        await emitItemsReloadRetrieved(emit, loadedItems);
      }
    } catch (e) {
      debugPrint('Error: $runtimeType onReloadItemsRequested: $e');
      await onLoadItemsException(emit, e);
      rethrow;
    }
  }

  Future<List<Section>> loadItemsFromCloud(
          Emitter<ItemsManagerState> emit) async =>
      await repo?.loadItemsFromCloud() ?? [];
  Future<List<Section>> loadItemsFromLocalStorage(
          Emitter<ItemsManagerState> emit) async =>
      await repo?.loadItemsFromLocalStorage() ?? [];

  FutureOr<void> emitItemsRetrieved(
      Emitter<ItemsManagerState> emit, List<Section> items) async {
    final st = state;
    if (st is ItemsRetrievedState) {
      await replaceAllItems(
        st,
        emit,
        items,
        firstTime: true,
      );
    } else {
      emit(ItemsRetrievedState(items: items));
    }
  }

  Future<void> replaceAllItems(ItemsRetrievedState st,
      Emitter<ItemsManagerState> emit, List<Section> sections,
      {bool firstTime = false}) async {
    for (var i = 0; i < st.sections.length; i++) {
      while (st.sections[i].items.isNotEmpty) {
        final item = st.sections[i].items.removeAt(0);
        emit(
          ItemRemovedState(
            itemSection: i,
            reachedBottom: st.reachedBottom,
            itemIndex: 0,
            removedItem: item,
            sections: st.sections,
          ),
        );
      }
    }
    var indx = 0;

    for (var i = 0; i < sections.length; i++) {
      if (st.sections.length <= i) {
        st.sections.add(sections[i].copyWith(items: <dynamic>[]));
      }
      for (final item in sections[i].items) {
        st.sections[i].items.add(item);
        final isLastItem =
            (indx == sections[i].items.length - 1) && i == sections.length - 1;
        var reachedBottom = !firstTime || !isLastItem
            ? st.reachedBottom
            : hasReachedBottom(i, sections[i].items);

        emit(
          ItemInsertedState(
            itemSection: i,
            itemIndex: indx++,
            reachedBottom: reachedBottom,
            insertedItem: item,
            sections: st.sections,
            animated: false,
          ),
        );

        if (firstTime && isLastItem && reachedBottom) {
          try {
            _insertBottomSpacer(
              state as LoadedState,
              emit,
            );
          } catch (e) {
            debugPrint(
                'Error: replaceAllItems $runtimeType insertBottomSpacer: $e');
            await onLoadItemsException(emit, e);
            rethrow;
          }
        }
      }
    }
  }

  FutureOr<void> emitItemsReloadRetrieved(
      Emitter<ItemsManagerState> emit, List<Section> items) async {
    final st = state;
    if (st is ItemsRetrievedState) {
      await replaceAllItems(
        st,
        emit,
        items,
        firstTime: true,
      );
    } else {
      emit(ItemsRetrievedState(items: items));
    }
  }

  @protected
  Future<List<Section>> loadingSkeletons() async => [];

  @protected
  FutureOr<void> onLoadItemsRequested(
      LoadItemsEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is LoadingMoreItemsState) return;
    final skeletons = await loadingSkeletons();
    final hasSkeletons = skeletons.isNotEmpty;
    if (hasSkeletons) {
      emit(
        ItemsRetrievedState(
          items: skeletons,
          reachedBottom: true,
        ),
      );
    } else {
      emit(const ItemsLoadingState());
    }
    try {
      var loadedItems = await loadItemsFromLocalStorage(emit);
      if (loadedItems.isNotEmpty) {
        await emitItemsRetrieved(emit, loadedItems);
        return;
      }
      loadedItems = await loadItemsFromCloud(emit);
      await emitItemsRetrieved(emit, loadedItems);
    } catch (e) {
      debugPrint('Error: $runtimeType onLoadItemsRequested: $e');
      await onLoadItemsException(emit, e);
      rethrow;
    }
  }

  Future onLoadItemsException(
      Emitter<ItemsManagerState> emit, dynamic e) async {
    emit(LoadItemsFailedState(
        exceptionType: e is DioException
            ? NetworkExceptionType.other.fromCode(e.response?.statusCode)
            : NetworkExceptionType.other));
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
      loadedState.sections[lastSection].items.add(insertedItem);
      emit(
        ItemInsertedState(
          itemSection: lastSection,
          reachedBottom: loadedState.reachedBottom,
          itemIndex: lastItemIndex,
          insertedItem: insertedItem,
          sections: loadedState.sections,
          animated: false,
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
      Emitter<ItemsManagerState> emit, List<dynamic> items) async {
    var loadedState = state as LoadedState;
    var lastSection = loadedState.sections.length - 1;
    lastSection = lastSection < 0 ? 0 : lastSection;
    var reachedBottom = hasReachedBottom(lastSection, items);
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
        debugPrint('Error: $runtimeType emitMoreItemsRetrieved: $e');
        await onLoadItemsException(emit, e);
        rethrow;
      }
    }

    var indx = 0;
    for (var item in items) {
      loadedState.sections[lastSection].items.add(item);
      emit(
        ItemInsertedState(
          reachedBottom: reachedBottom,
          itemSection: lastSection,
          itemIndex: indx++,
          insertedItem: item,
          sections: loadedState.sections,
          animated: false,
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
        debugPrint('Error: $runtimeType insertBottomSpacer: $e');
        await onLoadItemsException(emit, e);
        rethrow;
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
          animated: false,
        ),
      );
    }
  }

  @protected
  FutureOr<void> onLoadMoreItemsEvent(
      LoadMoreItemsEvent event, Emitter<ItemsManagerState> emit) async {
    if (state is! LoadedState) return;
    var loadedState = state as LoadedState;
    if (loadedState.reachedBottom) return;
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
      debugPrint('Error: $runtimeType onLoadMoreItemsEvent  $e');
      await onLoadMoreItemsException(emit, loadedState, e);
      rethrow;
    }
  }

  Future onLoadMoreItemsException(Emitter<ItemsManagerState> emit,
      LoadedState loadedState, dynamic e) async {
    emit(
      LoadMoreItemsFailedState(
          reachedBottom: false,
          sections: loadedState.sections,
          exceptionType: e is DioException
              ? NetworkExceptionType.other.fromCode(e.response?.statusCode)
              : NetworkExceptionType.other),
    );
  }
}
