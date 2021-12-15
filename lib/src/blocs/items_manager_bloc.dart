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

  ItemsManagerBloc({required this.repository}) : super(ItemsLoading()){
    on<LoadItemsRequested>(_onLoadItemsRequested);
    on<ReloadItemsRequested>(_onReloadItemsRequested);
  }

  int get totalSections => _items.length;

  int totalSectionItems(int section) => _items[section].items.length;

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  bool isSectionEmpty(int section) => _items[section].items.isEmpty;

  bool isSectionNotEmpty(int section) => _items[section].items.isNotEmpty;
  Section section(int section) => _items[section];
  bool usesGrid(int section) => _items[section].usesGrid;

  dynamic sectionHeader(int section) => _items[section].sectionHeader;


  FutureOr<void> _onReloadItemsRequested(
      ReloadItemsRequested event,
      Emitter<ItemsManagerState> emit) async {
    try {
      emit(ItemsLoading());
      if (event.fromCloud) {
        _items = await repository.loadItemsFromCloud();
        if (isNotEmpty || !event.loadFromLocalIfCloudEmpty) {
          emit(ItemsLoaded());
          return;
        }
        emit(ReloadFromCloudEmpty());
        _items = await repository.loadItemsFromLocalStorage();
        emit(ItemsLoaded());
      } else {
        _items = await repository.loadItemsFromLocalStorage();
        emit(ItemsLoaded());
      }
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailed());
    }
  }

  FutureOr<void> _onLoadItemsRequested(
      LoadItemsRequested event,
      Emitter<ItemsManagerState> emit) async {
    try {
      _items = await repository.loadItemsFromLocalStorage();
      if (isNotEmpty) {
        emit(ItemsLoaded());
        return;
      }
      _items = await repository.loadItemsFromCloud();
        emit(ItemsLoaded());
    } catch (e) {
      if (kDebugMode) print(e);
      emit(LoadItemsFailed());
    }
  }
}
