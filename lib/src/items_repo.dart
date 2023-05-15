import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepo {

  const ItemsRepo();
  Future<List<Section>> loadItemsFromLocalStorage() async => [];

  Future<List<Section>> loadItemsFromCloud() async => [];
}
