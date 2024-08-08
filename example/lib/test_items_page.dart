import 'package:example/test_items_bloc.dart';
import 'package:flora_core/flora_core.dart';
import 'package:flutter/material.dart';

class TestItemsPage extends ItemsListState<TestItemsBloc> {
  @override
  Widget buildItem({
    required BuildContext context,
    required int section,
    required int index,
    required item,
    Animation<double>? animation,
    bool isReplace = false,
    bool isRemoved = false,
  }) {
    if (item is int) {
      return ListTile(
        title: Text('Item $item'),
      );
    }
    return super.buildItem(
      context: context,
      section: section,
      index: index,
      item: item,
      animation: animation,
      isReplace: isReplace,
      isRemoved: isRemoved,
    );
  }
}
