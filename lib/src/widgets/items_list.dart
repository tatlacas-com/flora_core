import 'package:flutter/material.dart';
import 'package:flora_core/flora_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// {@template itemsList}
/// A base class for showing list or grid of widgets on ui. For sample see [ItemsManagerBloc]
/// {@endtemplate}
class ItemsList<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  const ItemsList({
    super.key,
    this.builder,
    this.buildSliversInSliverOverlapInjector = false,
  });
  final ItemsListState<TBloc> Function()? builder;

  final bool buildSliversInSliverOverlapInjector;

  @override
  ItemsListState<TBloc> createState() =>
      // ignore: no_logic_in_create_state
      builder?.call() ?? ItemsListState<TBloc>();
}

class ItemsListWidget<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ItemsListWidget({
    super.key,
    this.builder,
    this.listBuilderKey,
  });
  final ItemsListState<TBloc> Function()? builder;
  final Key? listBuilderKey;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScrollNotificationBloc(),
      child: ItemsList<TBloc>(
        key: listBuilderKey,
        builder: builder,
      ),
    );
  }
}
