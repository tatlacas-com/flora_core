import 'package:flutter/material.dart';
import 'package:flora_core/flora_core.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  const ListContainer({
    super.key,
    this.listBuilderKey,
    this.buildInBase = true,
    this.useScaffold = true,
    required this.builder,
  });
  final ItemsListState<TBloc> Function(BuildContext context) builder;
  final Key? listBuilderKey;

  /// Set false if you want to override and construct own widgets. Defaults to true
  final bool buildInBase;

  /// if true, build() will use Scaffold widget. Defaults to true
  final bool useScaffold;

  @override
  Widget build(BuildContext context) {
    if (!buildInBase) return const SizedBox.shrink();
    if (useScaffold) {
      return Scaffold(
        body: ItemsListWidget<TBloc>(
          key: listBuilderKey,
          builder: builder,
        ),
      );
    } else {
      return ItemsListWidget<TBloc>(
        key: listBuilderKey,
        builder: builder,
      );
    }
  }
}
