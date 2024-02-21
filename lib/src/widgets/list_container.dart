import 'package:flutter/material.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'items_list.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ListContainer({
    super.key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.listStateBuilder,
    this.appBar,
  });
  final PreferredSizeWidget? appBar;
  final ItemsListState<TBloc> Function() listStateBuilder;
  final Key? listBuilderKey;
  final bool buildInBase;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    if (!buildInBase) return const SizedBox();
    if (useScaffold) {
      return Scaffold(
        appBar: appBar ?? ZeroHeightAppBar(),
        body: ItemsList<TBloc>(
            key: listBuilderKey, stateBuilder: listStateBuilder),
      );
    } else {
      return ItemsList<TBloc>(
          key: listBuilderKey, stateBuilder: listStateBuilder);
    }
  }
}
