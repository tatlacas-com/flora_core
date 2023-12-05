import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepo {
  const ItemsRepo();
  Future<LoadItemsResult<Section>> loadItemsFromLocalStorage() async =>
      LoadItemsResult<Section>.empty();

  Future<LoadItemsResult<Section>> loadItemsFromCloud() async =>
      LoadItemsResult<Section>.empty();
  int get pageSize => 20;
}
