import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

import 'items_list.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ListContainer({
    super.key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.builder,
    this.appBar,
  });
  final PreferredSizeWidget? appBar;
  final ItemsListState<TBloc> Function() builder;
  final Key? listBuilderKey;
  final bool buildInBase;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    if (!buildInBase) return const SizedBox();
    if (useScaffold) {
      return Scaffold(
        appBar: appBar ?? ZeroHeightAppBar(),
        body: BlocProvider(
          create: (context) => ScrollNotificationBloc(),
          child: ItemsList<TBloc>(key: listBuilderKey, builder: builder),
        ),
      );
    } else {
      return BlocProvider(
        create: (context) => ScrollNotificationBloc(),
        child: ItemsList<TBloc>(key: listBuilderKey, builder: builder),
      );
    }
  }
}
