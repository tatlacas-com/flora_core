import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepo {
  const ItemsRepo();
  Future<ResponseItems<Section>> loadItemsFromLocalStorage() async =>
      ResponseItems<Section>.empty();

  Future<ResponseItems<Section>> loadItemsFromCloud() async =>
      ResponseItems<Section>.empty();
  int get pageSize => 20;
}
