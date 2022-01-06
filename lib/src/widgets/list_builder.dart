import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/blocs/items_manager_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/items_list.dart';

class ListBuilder<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  final Widget Function(BuildContext)? listBuilder;
  final ItemsListState<TBloc> Function()? listStateBuilder;

  const ListBuilder({
    Key? key,
    this.stateBuilder,
    this.listBuilder,
    this.listStateBuilder,
  })  : assert(listBuilder == null || listStateBuilder == null),
        super(key: key);

  bool get useNestedScrollView => true;

  bool get floatHeaderSlivers => false;
  final State<ListBuilder> Function()? stateBuilder;

  @override
  State<ListBuilder> createState() =>
      stateBuilder?.call() ?? ListBuilderState<ListBuilder<TBloc>, TBloc>();
}

class ListBuilderState<T extends ListBuilder<TBloc>,
    TBloc extends ItemsManagerBloc> extends State<T> {
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

  List<Widget> buildAppBarSlivers(
      BuildContext context, bool innerBoxIsScrolled) {
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
    if (state is LoadItemsFailed) return _buildLoadingFailed(context);
    if (state is LoadItemsFailed) return _buildLoadingFailed(context);
    if(state is ItemsLoaded)
    return widget.listBuilder?.call(context) ??
        ItemsList<TBloc>(stateBuilder: widget.listStateBuilder);
    throw ArgumentError('Not supported state $state');
  }

  Widget _buildLoadingFailed(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        var bloc = context.read<TBloc>();
        bloc.add(ReloadItemsRequested(context: context));
      },
      child: CustomScrollView(
        key: PageStorageKey<String>(TBloc.runtimeType.toString()),
        slivers: buildLoadingFailedSlivers(context),
      ),
    );
  }

  List<Widget> buildLoadingFailedSlivers(BuildContext context) {
    return [
      SliverPadding(
        padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
        sliver: SliverFillRemaining(
          hasScrollBody: false,
          child: buildLoadingFailedWidget(context),
        ),
      )
    ];
  }

  Widget buildLoadingFailedWidget(BuildContext context) {
    return Center(
      child: Text('Show Screen Failed to load items widget here...'),
    );
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

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }
}
