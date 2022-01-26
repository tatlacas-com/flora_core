import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'items_list.dart';
import 'list_builder.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final TBloc Function(BuildContext context) bloc;
  final PreferredSizeWidget? appBar;
  final State<ListBuilder<TBloc>> Function()? stateBuilder;
  final Widget Function(BuildContext)? listBuilder;
  final ItemsListState<TBloc> Function()? listStateBuilder;
  final Key? listBuilderKey;

  const ListContainer({
    Key? key,
    this.listBuilderKey,
    required this.bloc,
    this.stateBuilder,
    this.listBuilder,
    this.listStateBuilder,
    this.appBar,
  })  : assert(listBuilder == null || listStateBuilder == null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: BlocProvider(
        create: (context) =>
            this.bloc.call(context)..add(LoadItemsRequested(context: context)),
        child: ListBuilder<TBloc>(
          key: listBuilderKey,
          stateBuilder: stateBuilder ??
              () => ListBuilderState<ListBuilder<TBloc>, TBloc>(),
          listStateBuilder: listStateBuilder,
          listBuilder: listBuilder,
        ),
      ),
    );
  }
}
