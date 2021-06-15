import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/items_list_widget.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

class ItemsListScreen<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  const ItemsListScreen({Key? key,this.buildBodyContent}) : super(key: key);

  bool get useNestedScrollView => true;
  bool get floatHeaderSlivers => false;
  final Widget Function(BuildContext context)? buildBodyContent;

  @override
  ItemsListScreenState createState() => ItemsListScreenState<TBloc>();
}

class ItemsListScreenState<TBloc extends ItemsManagerBloc>
    extends State<ItemsListScreen> {
  ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: buildScaffoldBody(),
    );
  }

  List<Widget> buildAppBarSlivers(BuildContext context, innerBoxIsScrolled) {
    return [];
  }

  Widget buildScaffoldBody() {
    return widget.useNestedScrollView
        ? NestedScrollView(
            controller: scrollController,
            floatHeaderSlivers: widget.floatHeaderSlivers,
            headerSliverBuilder: buildAppBarSlivers,
            body: buildBody(),
          )
        : buildBody();
  }


  Widget buildBody() {
    return SafeArea(
        child: BlocBuilder<TBloc, ItemsManagerState>(
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        if (state is ItemsLoading) return buildLoadingView();
        if (state is LoadItemsFailed)
          return Center(
            child: Text('Failed to load items'),
          );
        return widget.buildBodyContent?.call(context) ?? buildBodyContent(context);
      },
    ));
  }

  Widget buildLoadingView() {
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
