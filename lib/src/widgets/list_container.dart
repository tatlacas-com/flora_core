import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'items_list.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final TBloc Function(BuildContext context) bloc;
  final PreferredSizeWidget? appBar;
  final ItemsListState<TBloc> Function() listStateBuilder;
  final Key? listBuilderKey;

  const ListContainer({
    Key? key,
    this.listBuilderKey,
    required this.bloc,
    required this.listStateBuilder,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: BlocProvider(
        create: (context) =>
            this.bloc.call(context)..add(LoadItemsEvent(context: context)),
        child: ItemsList<TBloc>(key: listBuilderKey, stateBuilder: listStateBuilder),
      ),
    );
  }
}
