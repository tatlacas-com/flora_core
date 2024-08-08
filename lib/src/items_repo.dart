import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepo {
  const ItemsRepo();
  Future<ResponseItems<Section>> getLocalItems() async =>
      ResponseItems<Section>.empty();

  Future<ResponseItems<Section>> getRemoteItems() async =>
      ResponseItems<Section>.empty();
  int get pageSize => 20;
}
