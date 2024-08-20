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
    required this.context,
    this.withSliverOverlapInjector = false,
  });
  final BuildContext context;
  final ItemsListState<TBloc> Function(BuildContext context)? builder;

  final bool withSliverOverlapInjector;

  @override
  ItemsListState<TBloc> createState() =>
      // ignore: no_logic_in_create_state
      builder?.call(context) ?? ItemsListState<TBloc>();
}

class ItemsListWidget<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ItemsListWidget({
    super.key,
    this.builder,
    this.listBuilderKey,
    this.withSliverOverlapInjector = false,
  });
  final ItemsListState<TBloc> Function(BuildContext context)? builder;
  final Key? listBuilderKey;
  final bool withSliverOverlapInjector;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ScrollNotificationBloc(),
      child: ItemsList<TBloc>(
        key: listBuilderKey,
        context: context,
        builder: builder,
        withSliverOverlapInjector: withSliverOverlapInjector,
      ),
    );
  }
}
