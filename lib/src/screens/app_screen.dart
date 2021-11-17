import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/zero_height_app_bar.dart';

import 'items_list_screen.dart';

class AppScreen extends StatelessWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;

  const AppScreen({
    Key? key,
    required this.body,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: body,
    );
  }
}

class AppListScreen<TBloc extends ItemsManagerBloc> extends StatelessWidget {
  final TBloc Function() bloc;
  final PreferredSizeWidget? appBar;
  final State<ItemsListScreen> Function() screen;

  const AppListScreen({
    Key? key,
    required this.bloc,
    required this.screen,
    this.appBar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar ?? ZeroHeightAppBar(),
      backgroundColor: Theme.of(context).backgroundColor,
      body: BlocProvider(
        create: (context) => this.bloc.call()..add(LoadItemsRequested()),
        child: ItemsListScreen<TBloc>(
          onCreateState: screen,
        ),
      ),
    );
  }
}
