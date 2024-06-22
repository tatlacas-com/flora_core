import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flora_core/flora_core.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ListContainer({
    super.key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.builder,
  });
  final ItemsListState<TBloc> Function() builder;
  final Key? listBuilderKey;
  final bool buildInBase;
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    if (!buildInBase) return const SizedBox();
    if (useScaffold) {
      return Scaffold(
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
