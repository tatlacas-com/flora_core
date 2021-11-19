import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/items_list_widget.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

class ItemsListScreen<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  const ItemsListScreen({Key? key,this.buildBodyContent,this.onCreateState}) : super(key: key);

  bool get useNestedScrollView => true;
  bool get floatHeaderSlivers => false;
  final Widget Function(BuildContext context)? buildBodyContent;
  final State<ItemsListScreen> Function()? onCreateState;

  @override
  State<ItemsListScreen> createState() => onCreateState?.call() ?? ItemsListScreenState<ItemsListScreen,TBloc>();
}

class ItemsListScreenState<T extends ItemsListScreen,TBloc extends ItemsManagerBloc>
    extends State<T> {
  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return widget.useNestedScrollView
        ? NestedScrollView(
      controller: scrollController,
      floatHeaderSlivers: widget.floatHeaderSlivers,
      headerSliverBuilder: buildAppBarSlivers,
      body: buildBody(context),
    )
        : buildBody(context);
  }

  List<Widget> buildAppBarSlivers(BuildContext context,bool innerBoxIsScrolled) {
    return [];
  }


  Widget buildBody(BuildContext context) {
    return SafeArea(
        child: BlocBuilder<TBloc, ItemsManagerState>(
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        return buildOnStateChanged(state, context);
      },
    ));
  }

  Widget buildOnStateChanged(ItemsManagerState state, BuildContext context) {
      if (state is ItemsLoading) return buildLoadingView(context);
    if (state is LoadItemsFailed)
      return Center(
        child: Text('Failed to load items'),
      );
    return widget.buildBodyContent?.call(context) ?? buildBodyContent(context);
  }

  Widget buildLoadingView(BuildContext context) {
    return Center(
      child: SizedBox(
        child: CircularProgressIndicator(),
        width: 60,
        height: 60,
      ),
    );
  }

  Widget buildBodyContent(BuildContext context) {
   return ItemsList<TBloc>();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
