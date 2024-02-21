import 'dart:async';

import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/i_serializable_item.dart';
import 'package:tatlacas_flutter_core/src/models/tapped_item_kind.dart';

import 'models/section.dart';

abstract class ItemsRepo<T extends PersistableMixin> {
  const ItemsRepo();
  Future<LoadItemsResult<Section<T>>> loadItemsFromLocalStorage({
    required ThemeData theme,
    required Function(String url, TappedItemKind kind) onTapUrl,
  }) async =>
      LoadItemsResult<Section<T>>.empty();

  Future<LoadItemsResult<Section<T>>> loadItemsFromCloud({
    required ThemeData theme,
    required Function(String url, TappedItemKind kind) onTapUrl,
  }) async =>
      LoadItemsResult<Section<T>>.empty();
  int get pageSize => 20;
}
