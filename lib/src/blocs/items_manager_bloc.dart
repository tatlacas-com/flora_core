import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode, protected;
import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/section.dart';

import '../items_repository.dart';

part 'items_manager_event.dart';

part 'items_manager_state.dart';

abstract class ItemsManagerBloc<TRepo extends ItemsRepository>
    extends Bloc<ItemsManagerEvent, ItemsManagerState> {
  final TRepo repository;

  List<Section> _items = [];

  List<Section> get items => _items;

  ItemsManagerBloc({required this.repository}) : super(ItemsLoading()) {
    on<LoadItemsRequested>(onLoadItemsRequested);
    on<ReloadItemsRequested>(onReloadItemsRequested);
  }

  int get totalSections => items.length;

  int totalSectionItems(int section) => items[section].items.length;

  bool get isEmpty => items.isEmpty;

  bool get isNotEmpty => !isEmpty;

  bool isSectionEmpty(int section) => items[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => items[section].items.isNotEmpty;

  Section section(int section) => items[section];

  bool usesGrid(int section) => items[section].usesGrid;

  dynamic sectionHeader(int section) => items[section].sectionHeader;

  @protected
  FutureOr<void> onReloadItemsRequested(
      ReloadItemsRequested event, Emitter<ItemsManagerState> emit) async {
    try {
      emit(ItemsLoading());
      if (event.fromCloud) {
        var _items = await repository.loadItemsFromCloud(event.context);
        items.clear();
        if (_items.isNotEmpty) items.addAll(_items);
        if (isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          emit(ItemsLoaded());
          return;
        }
        emit(ReloadFromCloudEmpty());
        _items = await repository.loadItemsFromLocalStorage(event.context);
        items.clear();
        if (_items.isNotEmpty) items.addAll(_items);
        emit(ItemsLoaded());
      } else {
        var _items = await repository.loadItemsFromLocalStorage(event.context);
        items.clear();
        if (_items.isNotEmpty) items.addAll(_items);
        emit(ItemsLoaded());
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
      var _items = await repository.loadItemsFromLocalStorage(event.context);
      items.clear();
      if (_items.isNotEmpty) items.addAll(_items);
      if (isNotEmpty) {
        emit(ItemsLoaded());
        return;
      }
      _items = await repository.loadItemsFromCloud(event.context);
      items.clear();
      if (_items.isNotEmpty) items.addAll(_items);
      emit(ItemsLoaded());
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailed());
    }
  }
}
