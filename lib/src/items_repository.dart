import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'models/section.dart';

abstract class ItemsRepository {
  Future<List<Section>> loadItemsFromLocalStorage(BuildContext context) async =>
      [];

  Future<List<Section>> loadItemsFromCloud(BuildContext context) async => [];

  const ItemsRepository();
}
