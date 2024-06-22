import 'package:flutter/material.dart';
import 'package:flora_core/flora_core.dart';

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
