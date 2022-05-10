import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'models/section.dart';

abstract class ItemsRepo {
  Future<List<Section>> loadItemsFromLocalStorage(BuildContext context) async =>
      [];

  Future<List<Section>> loadItemsFromCloud(BuildContext context) async => [];
  Future<void> loadMoreItems(BuildContext context) async => [];

  const ItemsRepo();
}
