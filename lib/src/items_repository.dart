import 'dart:async';

import 'models/section.dart';

abstract class ItemsRepository{
  Future<List<Section>> loadItemsFromLocalStorage() async=>[];
  Future<List<Section>> loadItemsFromCloud()async=>[];
  const ItemsRepository();
}