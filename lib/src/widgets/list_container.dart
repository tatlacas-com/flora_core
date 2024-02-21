import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/models/i_serializable_item.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

class ListContainer<T extends SerializableItem, TRepo extends ItemsRepo<T>,
    TBloc extends ItemsManagerBloc<T, TRepo>> extends StatelessWidget {
  const ListContainer({
    super.key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.listStateBuilder,
    this.appBar,
  });
  final PreferredSizeWidget? appBar;
  final ItemsListState<T, TRepo, TBloc> Function() listStateBuilder;
  final Key? listBuilderKey;
  final bool buildInBase;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    if (!buildInBase) return const SizedBox();
    if (useScaffold) {
      return Scaffold(
        appBar: appBar ?? ZeroHeightAppBar(),
        body: ItemsList<T, TRepo, TBloc>(
            key: listBuilderKey, stateBuilder: listStateBuilder),
      );
    } else {
      return ItemsList<T, TRepo, TBloc>(
          key: listBuilderKey, stateBuilder: listStateBuilder);
    }
  }
}
