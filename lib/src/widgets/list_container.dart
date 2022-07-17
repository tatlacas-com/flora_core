import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'items_list.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final ItemsListState<TBloc> Function() listStateBuilder;
  final Key? listBuilderKey;
  final bool buildInBase;
  final bool useScaffold;

  const ListContainer({
    Key? key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.listStateBuilder,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<TBloc>();
    if (bloc.state is ItemsInitialState) {
      bloc.add(LoadItemsEvent());
    }
    if(!buildInBase) return const SizedBox();
    if(useScaffold) {
      return Scaffold(
        appBar: appBar ?? ZeroHeightAppBar(),
        body:
        ItemsList<TBloc>(key: listBuilderKey, stateBuilder: listStateBuilder),
      );
    }else{
      return ItemsList<TBloc>(key: listBuilderKey, stateBuilder: listStateBuilder);
    }
  }
}
