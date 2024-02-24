import 'dart:async';

import 'package:flutter/material.dart';

import 'models/section.dart';

abstract class ItemsRepo {
  const ItemsRepo();
  Future<LoadItemsResult<Section>> loadItemsFromLocalStorage({
    required ThemeData theme,
  }) async =>
      LoadItemsResult<Section>.empty();

  Future<LoadItemsResult<Section>> loadItemsFromCloud({
    required ThemeData theme,
  }) async =>
      LoadItemsResult<Section>.empty();
  int get pageSize => 20;
}
