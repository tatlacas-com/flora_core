import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:tatlacas_flutter_core/src/models/section.dart';

import '../items_repository.dart';

part 'items_manager_event.dart';

part 'items_manager_state.dart';

abstract class ItemsManagerBloc<TRepo extends ItemsRepository>
    extends Bloc<ItemsManagerEvent, ItemsManagerState> {
  final TRepo repository;

  List<Section> _items = [];

  List<Section> get items => _items;

  ItemsManagerBloc({required this.repository}) : super(ItemsLoading());

  int get totalSections => _items.length;

  int totalSectionItems(int section) => _items[section].items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  bool isSectionEmpty(int section) => _items[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => _items[section].items.isNotEmpty;
  Section section(int section) => _items[section];
  bool usesGrid(int section) => _items[section].usesGrid;

  dynamic sectionHeader(int section) => _items[section].sectionHeader;

  @override
  Stream<ItemsManagerState> mapEventToState(
    ItemsManagerEvent event,
  ) async* {
    if (event is LoadItemsRequested) {
      yield* _mapLoadItemsToState(event);
    } else if (event is ReloadItemsRequested) {
      yield* _mapReloadItemsToState(event);
    }
  }

  Stream<ItemsManagerState> _mapReloadItemsToState(
      ReloadItemsRequested event) async* {
    try {
      yield ItemsLoading();
      if (event.fromCloud) {
        _items = await repository.loadItemsFromCloud();
        if (isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          yield ItemsLoaded();
          return;
        }
        yield ReloadFromCloudEmpty();
        _items = await repository.loadItemsFromLocalStorage();
        yield ItemsLoaded();
      } else {
        _items = await repository.loadItemsFromLocalStorage();
        yield ItemsLoaded();
      }
    } catch (e) {
      if (kDebugMode) print(e);
      yield LoadItemsFailed();
    }
  }

  Stream<ItemsManagerState> _mapLoadItemsToState(
      LoadItemsRequested event) async* {
    try {
      _items = await repository.loadItemsFromLocalStorage();
      if (isNotEmpty) {
        yield ItemsLoaded();
        return;
      }
      _items = await repository.loadItemsFromCloud();
      yield ItemsLoaded();
    } catch (e) {
      if (kDebugMode) print(e);
      yield LoadItemsFailed();
    }
  }
}
