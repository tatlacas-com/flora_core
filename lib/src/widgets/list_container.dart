import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'list_builder.dart';

class ListContainer<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final TBloc Function(BuildContext context) bloc;
  final PreferredSizeWidget? appBar;
  final State<ListBuilder> Function() stateBuilder;
  final Widget Function(BuildContext)? listBuilder;
  final Key? listBuilderKey;

  const ListContainer({
    Key? key,
    this.listBuilderKey,
    required this.bloc,
    required this.stateBuilder,
    this.listBuilder,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: BlocProvider(
        create: (context) => this.bloc.call(context)..add(LoadItemsRequested()),
        child: ListBuilder<TBloc>(
          key: listBuilderKey,
          stateBuilder: stateBuilder,
          listBuilder: listBuilder,
        ),
      ),
    );
  }
}
