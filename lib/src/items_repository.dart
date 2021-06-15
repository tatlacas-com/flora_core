import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepository{
  Future<List<Section>> loadItemsFromLocalStorage();
  Future<List<Section>> loadItemsFromCloud();
  const ItemsRepository();
}