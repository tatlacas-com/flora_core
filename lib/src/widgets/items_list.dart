import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tatlacas_flutter_core/src/widgets/items_slivers_mixin.dart';
import 'package:tatlacas_flutter_core/tatlacas_flutter_core.dart';

/// {@template itemsList}
/// A base class for showing list or grid of widgets on ui. For sample see [ItemsManagerBloc]
/// {@endtemplate}
class ItemsList<TBloc extends ItemsManagerBloc> extends StatefulWidget {
  const ItemsList({
    super.key,
    this.stateBuilder,
    this.buildSliversInSliverOverlapInjector = false,
  });
  final ItemsListState<TBloc> Function()? stateBuilder;

  final bool buildSliversInSliverOverlapInjector;

  @override
  ItemsListState<TBloc> createState() =>
      // ignore: no_logic_in_create_state
      stateBuilder?.call() ?? ItemsListState<TBloc>();
}

class ItemsListState<TBloc extends ItemsManagerBloc>
    extends State<ItemsList<TBloc>>
    with AutomaticKeepAliveClientMixin, ItemsSliversMixin<TBloc> {
  ItemsListState({
    ScrollController? nestedScrollController,
    this.customScrollController,
    this.scrollPhysics,
  }) {
    _disposeController = nestedScrollController == null;
    this.nestedScrollController = nestedScrollController ?? ScrollController();
  }
  late bool _disposeController;

  double get reloadThresholdPixels => 250;

  bool get pullToRefresh => true;

  bool get floatHeaderSlivers => false;

  bool get useNestedScrollView => true;

  late final ScrollController nestedScrollController;
  final ScrollController? customScrollController;
  final ScrollPhysics? scrollPhysics;

  bool get buildSliversInSliverOverlapInjector => false;

  @protected
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  final GlobalKey<NestedScrollViewState> nestedScrollViewGlobalKey =
      GlobalKey();
  ScrollController? get innerController {
    return useNestedScrollView
        ? nestedScrollViewGlobalKey.currentState!.innerController
        : null;
  }

  @override
  void initState() {
    super.initState();
    bloc = context.read<TBloc>();
  }

  @mustCallSuper
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return useNestedScrollView
        ? NestedScrollView(
            key: nestedScrollViewGlobalKey,
            controller: nestedScrollController,
            floatHeaderSlivers: floatHeaderSlivers,
            headerSliverBuilder: (BuildContext cnxt, bool innerBoxIsScrolled) {
              return buildAppBarSlivers(context);
            },
            body: buildScrollViewWithListeners(context),
          )
        : buildScrollViewWithListeners(context);
  }

  List<BlocListener> blocListeners(BuildContext context) => [];

  Widget buildScrollView(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        onScrollNotification(scrollInfo);
        return true;
      },
      child: pullToRefresh
          ? RefreshIndicator(
              key: refreshIndicatorKey,
              onRefresh: onRefreshIndicatorRefresh,
              child: buildCustomScrollView(context),
            )
          : buildCustomScrollView(context),
    );
  }

  Future onRefreshIndicatorRefresh() async {
    final reloading = bloc.stream
        .where((state) =>
            !(state is ReloadingItemsState || state is ItemsLoadingState))
        .first;
    bloc.add(ReloadItemsEvent());
    await reloading;
  }

  Widget buildScrollViewWithListeners(BuildContext context) {
    final listeners = blocListeners(context);
    if (listeners.isNotEmpty) {
      return MultiBlocListener(
        listeners: listeners,
        child: buildScrollView(context),
      );
    } else {
      return buildScrollView(context);
    }
  }

  Widget buildCustomScrollView(BuildContext context) {
    return BlocConsumer<TBloc, ItemsManagerState>(
      listener: (context, state) {
        if (state is ItemRemovedState) {
          removeItem(state);
        } else if (state is ItemInsertedState) {
          insertItem(state, animated: state.animated);
        } else if (state is ItemReplacedState) {
          replaceItem(state);
        }
      },
      listenWhen: (prev, next) => next is ItemChangedState,
      buildWhen: (prev, next) => next is ItemsBuildUi,
      builder: (context, state) {
        return buildOnStateChanged(context, state);
      },
    );
  }

  void replaceItem(ItemReplacedState state) {
    removeItem(
      ItemRemovedState(
        itemSection: state.itemSection,
        changeParams: state.changeParams,
        reachedBottom: state.reachedBottom,
        itemIndex: state.itemIndex,
        removedItem: state.removedItem,
        sections: state.sections,
      ),
      isReplace: true,
    );
    insertItem(
      ItemInsertedState(
        itemSection: state.itemSection,
        reachedBottom: state.reachedBottom,
        itemIndex: state.itemIndex,
        changeParams: state.changeParams,
        insertedItem: state.insertedItem,
        sections: state.sections,
      ),
      isReplace: true,
    );
  }

  void removeItem(
    ItemRemovedState state, {
    bool isReplace = false,
  }) {
    removeListItem(
      state: state,
      isReplace: isReplace,
    );
  }

  void insertItem(
    ItemInsertedState state, {
    bool isReplace = false,
    bool animated = false,
  }) {
    insertListItem(
      state: state,
      isReplace: isReplace,
      animated: animated,
    );
  }

  Widget buildOnStateChanged(
    BuildContext context,
    ItemsManagerState state,
  ) {
    if (state is ItemsLoadingState || state is ItemsInitialState) {
      return buildLoadingView(context);
    }
    if (state is LoadItemsFailedState) {
      return _buildLoadingFailed(state, context);
    }
    if (state is ItemsRetrievedState || state is LoadedState) {
      return buildItemsRetrievedScrollView(context);
    }
    throw ArgumentError('buildOnStateChanged Not supported state $state');
  }

  void onScrollNotification(ScrollNotification scrollInfo) {
    var diff = scrollInfo.metrics.maxScrollExtent - scrollInfo.metrics.pixels;
    if (diff < reloadThresholdPixels) {
      bloc.add(LoadMoreItemsEvent());
    }
  }

  Widget buildItemsRetrievedScrollView(BuildContext context) {
    var withInjector = widget.buildSliversInSliverOverlapInjector ||
        buildSliversInSliverOverlapInjector;
    final key = '${runtimeType}Items';
    return CustomScrollView(
      key: PageStorageKey<String>(key),
      physics: scrollPhysics ??
          const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      controller: customScrollController,
      //needed for RefreshIndicator to work
      slivers: withInjector
          ? buildSectionsWithOverlapInjector(context)
          : buildSections(context),
    );
  }

  Widget _buildLoadingFailed(LoadItemsFailedState state, BuildContext context) {
    return CustomScrollView(
      controller: useNestedScrollView ? null : customScrollController,
      key: PageStorageKey<String>(runtimeType.toString()),
      slivers: buildLoadingFailedSlivers(context, state),
    );
  }

  List<Widget> buildLoadingFailedSlivers(
      BuildContext context, LoadItemsFailedState state) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: buildLoadingFailedWidget(context, state),
      )
    ];
  }

  Widget buildLoadingFailedWidget(
      BuildContext context, LoadItemsFailedState state) {
    return const Center(
      child: Text('Show Screen Failed to load items widget here...'),
    );
  }

  Widget buildLoadingView(BuildContext context) {
    return Center(
      child: ListView(
        shrinkWrap: true,
        children: const [
          Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }

  List<Widget> buildSectionsWithOverlapInjector(BuildContext context) {
    var sections = buildSections(context);
    List<Widget> widgets = [
      SliverOverlapInjector(
// This is the flip side of the SliverOverlapAbsorber
// above.
        handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      ),
    ];
    widgets.addAll(sections);
    return widgets;
  }

  List<Widget> buildAppBarSlivers(BuildContext context) {
    return [];
  }

  @override
  void dispose() {
    if (_disposeController) {
      nestedScrollController.dispose();
    }

    super.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
