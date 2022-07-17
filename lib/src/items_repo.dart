import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'models/section.dart';

abstract class ItemsRepo {
  Future<List<Section>> loadItemsFromLocalStorage() async =>
      [];

  Future<List<Section>> loadItemsFromCloud() async => [];

  const ItemsRepo();
}
