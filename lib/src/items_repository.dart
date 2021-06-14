import 'dart:async';

abstract class ItemsRepository{
  Future<List<dynamic>> loadItemsFromLocalStorage();
  Future<List<dynamic>> loadItemsFromCloud();
  const ItemsRepository();
}